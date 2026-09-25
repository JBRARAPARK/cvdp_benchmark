# CVDP RTL 풀이 기록

원문을 읽고 작성한 RTL, 첫 제출·수정 이력, 평가 제출 파일, 원본 공식 테스트 결과와 별도 진단 결과를 함께 보관한다. 테스트를 본 뒤 수정한 성적은 첫 시도 성능과 구분한다.

| 묶음 | 내용 | 결과 문서 |
|---|---|---|
| 시작 예제 | LFSR 1개와 local_import 응답 | [RTL](../model_responses/lfsr_8bit.v) · [평가 기록](evaluation_evidence/work_llm_example_20260924_070948/report.txt) |
| 대표 10문제 | 첫 9/10 → 수정 10/10; 자판기 사양·호환 변형 별도 | [결과](representative_10/RESULTS_KO.md) |
| 추가 30문제 | 26/30; 별도 호환본 2개 포함 28/30. SPI·IRQ는 공식 미통과 | [결과](next_30/RESULTS_KO.md) · [마지막 2문제](next_30/final_two/README_KO.md) |
| 추가 50문제 | 첫 23/50 → 수정·통합 재평가 43/50 | [결과](next_50/RESULTS_KO.md) · [최종 RTL](next_50/final) |
| 남은 7문제 재풀이 | 호환 설정 4 PASS / 3 FAIL. 기존 43/50 집계 유지 | [결과](next_50/retry_20260925/README_KO.md) |

## 구성

- `../selections/`: 선정 목록, 원문·제공 코드, 평가용 원본 레코드. `selected.jsonl` 및 batch/dataset 파일에는 원본 정답 필드와 harness도 있으므로 독립 풀이에는 원문 또는 input-only 파일을 사용한다.
- 각 묶음의 `first/`: 첫 답안. `revised*`, `final*`, 호환 디렉터리는 해당 보고서를 따라 선택한다. 모든 `.sv`를 한꺼번에 컴파일하면 동일 모듈 정의가 겹친다.
- `evaluation_evidence/`: 임시 `work*` 폴더에서 보존한 결과·로그. [index.json](evaluation_evidence/index.json)에 원래 위치, 보관 위치, SHA-256이 있다. 원본 JSON 내부의 절대경로는 당시 실행 기록이며, 다른 컴퓨터에서는 index의 `archived` 경로를 사용한다.
- `../scripts/cvdp`: macOS/Homebrew/Colima의 `cvdp` 프로필용 실행 도구. 다른 환경에서는 Docker 설정 후 `python run_benchmark.py`를 직접 사용한다.

## 다시 평가하기

환경 설치는 [로컬 설정 안내](../LOCAL_SETUP_KO.md)와 저장소의 `requirements.txt`, `docker/Dockerfile.sim`을 참고한다. 로컬 `.env`와 가상환경, Docker VM은 커밋에 포함되지 않는다. API 키 없이 `local_import`로 이미 작성한 RTL의 객관적 테스트를 실행할 수 있다. Subjective scoring 경고가 있어도 주관 점수는 산출·주장하지 않는다.

저장소 루트에서 최종 50개 평가:

```sh
./scripts/cvdp benchmark \
  -f solutions/next_50/final/dataset.jsonl -l -m local_import \
  --prompts-responses-file solutions/next_50/final/responses.jsonl \
  -p work_next50_recheck
```

남은 7개의 호환 설정 재현:

```sh
./scripts/cvdp benchmark \
  -f solutions/next_50/retry_20260925/evaluation/dataset.jsonl -l -m local_import \
  --prompts-responses-file solutions/next_50/retry_20260925/evaluation/responses.jsonl \
  -p work_retry7_recheck
```

선정 원본의 대용량 전체 데이터셋, 임시 시뮬레이션 파일·파형은 제외했다. 위 제출 파일에는 해당 평가의 문제 레코드가 포함돼 있다. 과거 raw JSON의 경로 및 실행 시점 정보는 보존하고, 문서의 파일 링크는 가능한 한 저장소 상대경로로 바꿨다. archive/report 생성 스크립트 일부는 해당 원래 데이터셋과 `work*` 실행 폴더를 필요로 한다.

공식 PASS, 테스트용 호환 PASS, 별도 진단 PASS를 합쳐 모두 해결했다고 해석하지 않는다. 상세 한계는 각 보고서에 기록돼 있다.
