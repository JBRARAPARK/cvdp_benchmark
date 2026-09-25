# 남은 SPI·인터럽트 2문제 수정 결과

두 문제의 RTL 수정과 진단 검증을 완료했다. **진단 테스트는 모두 통과했지만, 변경하지 않은 공식 테스트는 둘 다 실패한다.** 따라서 기존 공식 집계 28/30(별도 호환본 2개 포함)은 유지한다. 원본 데이터셋과 공식 harness는 수정하지 않았다.

| 대상 | 원본 공식 | 보완한 진단 harness | 독립 경계조건 검사 |
|---|---|---|---|
| SPI | 실패: 15비트 관측 후 완료 기대 | 통과 | 276개 워드 전송, 124개 중단·리셋·fault 시나리오 통과 |
| 인터럽트 | 실패: 마스크 입력 미초기화 | 11/11 통과 (mask=0 초기화만 추가) | 임계값 1·5·20에서 24·28·43개 서비스 검사 및 제어 검사 통과 |

두 RTL 모두 Yosys `proc; opt; check -assert`에서 0 problems. 이는 합성 가능 구조 검사이며 배치·배선 또는 타이밍 검증은 아니다.

## SPI 수정

[최종 RTL](spi_fsm.sv) · [독립 테스트](spi_tb.sv)

- 시작 시 입력 16비트를 저장하여 전송 중 입력 변화의 영향을 없앴다.
- MSB부터 출력하고 SPI 상승 전에 한 시스템 주기 동안 데이터를 안정화한다.
- 16번째 상승까지 CS를 유지하고, 마지막 하강에서 clock을 0으로 돌린 뒤 CS를 해제하며 done을 한 주기 출력한다. 이전 버전의 완료 시 CS/clock이 활성 상태로 남는 부분을 수정했다.
- disable·clear·비동기 reset은 안전한 idle로 복귀한다. fault 진입 시 done을 한 주기 출력하고 ERROR를 유지한다. 원문에 fault done=0이라는 문구와 진입 시 pulse라는 문구가 함께 있으므로 후자를 따른다.

원본 테스트는 0~14번, 총 15비트만 검사한 뒤 바로 완료를 기대한다. 새 RTL의 원본 실패는 361ns에서 done=0인 것인데, 아직 16번째 비트를 보내야 하므로 완료를 앞당기지 않았다. 진단 테스트에는 안정화 대기 및 16번째 LSB와 남은 비트 0 검사를 추가했다. 기존 검사 항목을 삭제하거나 약화하지 않았다.

## 인터럽트 수정

[최종 RTL](interrupt_controller.sv) · [독립 테스트](interrupt_tb.sv)

- ACK/timeout으로 지우는 요청과 새 요청을 `(pending & ~serviced) | new_requests`로 합성하여 같은 시점의 새 요청을 보존한다.
- 대기 카운터 폭을 임계값에 맞춰 산출하고 포화시킨다. 이전 4비트 카운터는 20 같은 임계값에 도달할 수 없었다.
- 대기 횟수는 중재 기회마다 증가한다. 원문의 정확한 단위는 미지정이며 공식 테스트의 기대에 맞췄다. 클록마다 누적한 중간 구현은 진단 테스트 일부에서 우선순위 불일치가 발생했다.
- 기본 우선순위 10-ID, override, 임계값 도달 시 ID만큼 가산(최대 15), 동점은 큰 ID 우선을 적용한다. 활성 서비스의 ID는 override 변경에도 유지한다.
- 요청 수신부터 중재까지의 불필요한 idle 지연을 제거했다. ACK 시 valid/status를 해제하고 다음 중재로 진행한다.
- 기본 timeout 16주기이며 SERVICE_TIMEOUT으로 조정 가능하다. timeout IRQ를 missed에 기록하고 다음 요청으로 진행한다. reset_interrupts는 pending·상태·오류 기록을 초기화한다.

공식 테스트 초기화에는 interrupt_mask 구동이 빠져 있다. 이 입력에 0을 넣는 **한 줄만** 추가한 진단 harness에서 최종 RTL이 11개 테스트를 통과했다. RTL에서 X를 임의로 0으로 취급하거나 masking을 제거하지 않았다. 별도 테스트에서 10개 소스 모두 masking 및 missed 기록을 확인했다.

원문이 수치·단위를 정하지 않은 우선순위/aging/timeout 정책은 위처럼 명시적으로 선택했다. 이것이 유일한 가능한 구현이라는 의미는 아니다.

## 자료와 재현

- [공식과 진단 harness의 정확한 차이](diagnostic_harness.patch)
- [원본 공식 최종 결과](../../evaluation_evidence/work_next30_final_two_official2/raw_result.json)
- [진단 harness 통과 결과](../../evaluation_evidence/work_next30_final_two_diagnostic2/raw_result.json)
- [독립 검증 로그](../../../logs/next30-final-two-validation2.log)
- [합성 구조 검사 로그](../../../logs/next30-final-two-synthesis.log)
- [제출 및 진단 데이터 생성 스크립트](prepare_evaluation.py)

프로젝트 루트에서:

```sh
.venv/bin/python solutions/next_30/final_two/prepare_evaluation.py
./scripts/cvdp docker run --rm -v "$PWD/solutions/next_30/final_two:/code" -w /code nvidia/cvdp-sim:v1.0.0 sh run_validation.sh
./scripts/cvdp benchmark -f solutions/next_30/final_two/diagnostic_dataset.jsonl -l -m local_import --prompts-responses-file solutions/next_30/final_two/responses.jsonl -p work_next30_two_diagnostic_repeat
```

원본 평가를 재현하려면 diagnostic_dataset 대신 official_dataset을 사용하고 실행 폴더도 새 이름으로 지정한다. API 키는 RTL 평가에 필요하지 않다.
