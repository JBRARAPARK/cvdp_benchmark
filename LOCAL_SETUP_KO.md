# CVDP 로컬 평가 환경

경로: `/Users/bagjunbeom/Downloads/CVDP`

공식 저장소: https://github.com/NVlabs/cvdp_benchmark

설치 기준 커밋: `8e894cf74414ab1eaea1e2b4e80a02f123df07b6`

## 구성

- Python 3.12 및 `.venv`: 공식 `requirements.txt` 설치. 전체 설치 버전은 `requirements-local.lock.txt`에 기록.
- Docker / Docker Compose / Colima: Homebrew로 설치.
- 전용 Colima 프로필 `cvdp`: ARM64 Linux, CPU 4개, RAM 6 GiB, 최대 데이터 디스크 60 GiB.
- 시뮬레이션 이미지 `nvidia/cvdp-sim:v1.0.0`: 공식 `docker/Dockerfile.sim` 사용.
- `.env`: 비상용 시뮬레이션 이미지, 병렬 작업 1개, 주관적 LLM 채점 비활성화.
- `scripts/cvdp`: 프로젝트 가상환경과 Docker 소켓, Compose 플러그인을 자동 선택하는 실행 도구.

## 시작과 환경 확인

```bash
cd /Users/bagjunbeom/Downloads/CVDP
./scripts/cvdp start
./scripts/cvdp doctor
./scripts/cvdp smoke
```

`smoke`는 API 키 없이 공식 non-agentic 정답 예제를 평가합니다. 매번 새 `work_smoke_<날짜>_<시간>_<PID>/` 폴더에 `report.txt`, `report.json`, `raw_result.json`과 로그를 남깁니다.

작업을 마친 뒤 VM 메모리를 반환하려면 `./scripts/cvdp stop`을 실행하세요.

## 검증 결과 (2026-09-24)

- `./scripts/cvdp doctor`: Python 의존성, Docker, Compose, ARM64 시뮬레이션 이미지 확인 완료.
- 공식 정답 직접 평가: 1문제 / 1테스트 통과. 결과: `work_smoke_20260924_070730_82402/report.txt`.
- `local_import` 응답 파일 평가: 같은 예제 1문제 / 1테스트 통과. 결과: `work_import_check_20260924_070748/report.txt`.
- 가져오기 검증에는 공식 예제 정답을 응답 파일로 변환해 사용했습니다. 위 결과는 환경 검증이며 모델 성능 점수가 아닙니다.
- 실제 모델 응답 생성 및 전체 데이터셋 평가는 아직 실행하지 않았습니다.

## API 모델 평가 방법

`.env`의 `OPENAI_USER_KEY` 주석을 해제하고 키를 로컬에서 입력합니다. 실제 API 평가에는 해당 공급자의 사용료가 발생합니다.

먼저 예제 1문제로 확인:

```bash
./scripts/cvdp benchmark \
  -f example_dataset/cvdp_v1.1.0_example_nonagentic_code_generation_no_commercial_with_solutions.jsonl \
  -l -m gpt-4o-mini -p work_model_example
```

위 모델명은 upstream 기본 어댑터에 등록된 예시입니다. 다른 모델·공급자는 `-c /절대경로/custom_factory.py`로 어댑터를 지정하거나 아래 응답 파일 평가를 사용하세요.

다운로드된 전체 non-agentic 비상용 데이터 평가:

```bash
./scripts/cvdp samples \
  -f datasets/cvdp_v1.1.0_nonagentic_code_generation_no_commercial.jsonl \
  -l -m gpt-4o-mini -n 5 -k 1 -t 1 -p work_model_full
```

결과는 `work_model_full/composite_report.txt`에서 확인합니다. 재평가할 때는 새 `-p` 경로를 사용하세요. 기존 결과가 있으면 upstream 도구가 재사용합니다.

## 자체 모델 / 이미 생성한 응답 평가

프롬프트 내보내기:

```bash
./scripts/cvdp benchmark \
  -f datasets/cvdp_v1.1.0_nonagentic_code_generation_no_commercial.jsonl \
  -l -m local_export --prompts-responses-file work_export/prompts.jsonl \
  -p work_export
```

각 프롬프트를 평가할 모델에 입력한 뒤 응답을 JSONL로 저장합니다. 한 줄 형식은 `{"id":"문제 ID","completion":"모델이 생성한 원문 응답"}`입니다.

```bash
./scripts/cvdp benchmark \
  -f datasets/cvdp_v1.1.0_nonagentic_code_generation_no_commercial.jsonl \
  -l -m local_import --prompts-responses-file /절대경로/responses.jsonl \
  -p work_import
```

이 방식은 별도 API 키 없이 응답의 RTL을 시뮬레이션해 평가합니다. 내보내기와 가져오기는 서로 다른 `-p`를 사용하세요.

## 데이터와 범위

`datasets/`에는 공식 Hugging Face의 v1.1.0 non-agentic / agentic 비상용 code generation 데이터를 내려받았습니다. 출처·문제 수·체크섬은 `datasets/manifest.json`에 기록합니다.

- Non-agentic: 302문제. `work_export/prompts.jsonl`에 전체 프롬프트를 이미 생성하고 문제 ID 일치를 검증했습니다.
- Agentic: 92문제.
- 데이터셋 라이선스와 고지: `datasets/LICENSE`, `datasets/NOTICE`.

공개 전체 데이터에는 정답이 없으므로 모델 호출 또는 생성된 응답이 필요합니다. 환경 검증은 `example_dataset/`의 정답 포함 파일로 합니다.

Agentic 모델 평가에는 별도 에이전트 컨테이너가 필요합니다. 설정은 `README_AGENTIC.md`를 참고하세요. 상용 EDA 문제에는 별도 도구 이미지와 라이선스가 필요합니다.

## 재설치 및 이미지 빌드

```bash
brew install python@3.12 colima docker docker-compose
python3.12 -m venv .venv
.venv/bin/python -m pip install -r requirements-local.lock.txt
mkdir -p .docker-cvdp
printf '%s\n' '{"cliPluginsExtraDirs":["/opt/homebrew/lib/docker/cli-plugins"]}' > .docker-cvdp/config.json
# .env가 없다면 .env.example을 복사하고 OSS_SIM_IMAGE를 설정
./scripts/cvdp start
./scripts/cvdp build
./scripts/cvdp doctor
./scripts/cvdp smoke
```

초기 빌드 로그: `logs/image-build.log`. 이미지 빌드에는 네트워크와 C/C++ 컴파일 시간이 필요합니다.
