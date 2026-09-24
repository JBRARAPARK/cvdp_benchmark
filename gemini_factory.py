import os
import logging
from typing import Optional
from google import genai
from google.genai import types

try:
    from src.model_factory import ModelFactory
    from src.model_helpers import ModelHelpers
except ImportError:
    from src.llm_lib.model_factory import ModelFactory
    from src.model_helpers import ModelHelpers

class GeminiModel:
    def __init__(self, context: str = "You are an expert RTL engineer.", key=None, model="gemini-3.5-flash", **kwargs):
        self.context = context
        self.model = model
        
        api_key = os.getenv("GEMINI_API_KEY") or os.getenv("OPENAI_USER_KEY") or key
        if not api_key:
            raise ValueError("GEMINI_API_KEY가 설정되지 않았습니다. export GEMINI_API_KEY='your_key'를 확인하세요.")
        
        self.client = genai.Client(api_key=api_key)

    def prompt(self, prompt, schema: str = None, prompt_log: str = "", files: Optional[list] = None, timeout: int = 60, category: Optional[int] = None, **kwargs):
        helper = ModelHelpers()
        system_prompt = helper.create_system_prompt(self.context, schema, category)
        expected_single_file = files and len(files) == 1 and schema is None

        try:
            config = types.GenerateContentConfig(
                system_instruction=system_prompt
            )
            response = self.client.models.generate_content(
                model=self.model,
                contents=prompt,
                config=config
            )
            
            content = response.text.strip() if (response and response.text) else ""
            return helper.parse_model_response(content, files, expected_single_file)

        except Exception as e:
            logging.error(f"Gemini API Error: {str(e)}")
            raise ValueError(f"Gemini API 호출 실패: {str(e)}")

class CustomModelFactory(ModelFactory):
    def create_model(self, model_name, context=None, **kwargs):
        if "gemini" in model_name.lower():
            return GeminiModel(context=context, model=model_name, **kwargs)
        return super().create_model(model_name, context=context, **kwargs)
