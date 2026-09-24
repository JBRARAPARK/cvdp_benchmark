import os
import re
import json
import time
from google import genai
from google.genai import types
from src.llm_lib.model_factory import ModelFactory

class GeminiModel:
    def __init__(self, context=None, key=None, model="gemini-3.5-flash", **kwargs):
        self.model_name = model
        api_key = os.getenv("GEMINI_API_KEY") or os.getenv("OPENAI_USER_KEY") or key
        if not api_key:
            raise ValueError("GEMINI_API_KEY가 설정되지 않았습니다.")
        self.client = genai.Client(api_key=api_key)

    def _clean_verilog_code(self, text: str) -> str:
        if not text:
            return ""
        text = str(text).strip()
        match = re.search(r'```(?:verilog|systemverilog|v|sv)?\s*(.*?)\s*```', text, re.DOTALL | re.IGNORECASE)
        if match:
            text = match.group(1).strip()
        elif text.startswith("```") and text.endswith("```"):
            lines = text.splitlines()
            if len(lines) >= 2:
                text = "\n".join(lines[1:-1]).strip()
        return text

    def prompt(self, prompt, schema=None, prompt_log="", files=None, **kwargs):
        system_instruction = (
            "You are an expert RTL design engineer writing synthesizable SystemVerilog/Verilog code.\n"
            "Generate complete, correct, and synthesizable RTL code matching specifications."
        )

        config_args = {"system_instruction": system_instruction}
        
        # Schema가 넘겨지면 Gemini Native Structured Output 적용
        if schema:
            config_args["response_mime_type"] = "application/json"
            config_args["response_schema"] = schema

        config = types.GenerateContentConfig(**config_args)

        output_text = ""
        max_retries = 4

        for attempt in range(max_retries):
            try:
                response = self.client.models.generate_content(
                    model=self.model_name,
                    contents=prompt,
                    config=config
                )
                output_text = getattr(response, 'text', '') or ""
                if not output_text and hasattr(response, 'candidates') and response.candidates:
                    for part in response.candidates[0].content.parts:
                        if hasattr(part, 'text') and part.text:
                            output_text += part.text
                if output_text:
                    break
            except Exception as e:
                err_msg = str(e)
                print(f"\n❌ Gemini API Error ({self.model_name}, 시도 {attempt+1}/{max_retries}): {err_msg}")
                if "429" in err_msg or "RESOURCE_EXHAUSTED" in err_msg:
                    wait_sec = (attempt + 1) * 10
                    print(f"⏳ Rate Limit 발생. {wait_sec}초 대기 후 재시도...")
                    time.sleep(wait_sec)
                else:
                    break

        # Schema 요청 시 원본 JSON 반환, 미요청 시 순수 Verilog 코드 문자열 반환
        if schema:
            return output_text, prompt_log

        clean_code = self._clean_verilog_code(output_text)
        return clean_code, prompt_log

class CustomModelFactory(ModelFactory):
    def create_model(self, model_name, context=None, **kwargs):
        if "gemini" in model_name:
            return GeminiModel(context=context, model=model_name, **kwargs)
        return super().create_model(model_name, context=context, **kwargs)
