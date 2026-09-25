# 공식 미통과 7문제의 근거와 다음 조치

이 문서는 공식 테스트 실패와 원문 요구의 차이를 구분한다. 별도 진단 통과는 해당 동작만 확인하며, 공식 PASS 또는 전체 설계의 정합성을 의미하지 않는다. 원본 문제와 공식 harness는 수정하지 않았다.

| 번호 | 문제 | 확인한 차이 / 남은 원인 | 별도 진단 범위 | 다음 조치 |
|---:|---|---|---|---|
| 17 | SIPO + CRC | 공식 `test_sipo.py`는 마지막 직렬 비트를 적용하기 전에 저장한 `parallel_out_1`로 기대 CRC를 계산한다. RTL은 현재 SIPO 출력으로 CRC를 계산한다. 테스트는 DUT의 `done`도 직접 구동한다. | CRC 서브모듈에 서로 다른 100개 입력을 넣어 독립 다항식 계산과 대조. **SIPO/ECC 전체 통합 검증은 아님.** | 마지막 비트 반영 후 데이터를 캡처하고 CRC 등록 지연을 기다리는 별도 통합 테스트 필요. 공식 결과는 FAIL 유지. |
| 22 | 핑퐁 버퍼 | `async_reset_test`는 쓰기·읽기 입력을 초기화하지 않고 리셋을 해제한 뒤 2클록이 지난 상태에서 empty를 요구한다. 이전 테스트가 남긴 쓰기 활성 상태이면 정상적인 새 데이터 쓰기로 empty가 해제된다. 초기 답안의 총용량 512 해석도 테스트의 활성 뱅크 256과 달라 수정했다. | 256개 채우기/순서대로 읽기 2회, 뱅크 전환, 비동기 리셋 및 입력 비활성 상태 유지. | 독립된 입력 초기화로 공식 시나리오를 재현하는 진단 harness 필요. 리셋 직후 정상 쓰기를 무시하는 우회는 넣지 않음. |
| 30 | Wishbone→AHB | 원문은 endian 변환과 완료 후 ACK를 요구한다. 테스트는 `DEADBEEF`가 변환 없이 출력되기를 기대하며, ACK를 기다리지 않고 2개 AHB 에지 뒤 확인한다. 첫 답안에는 독립 클록용 요청/완료 동기화가 있다. | 서로 다른 WB/AHB 주기, 쓰기 바이트 순서 변환, wait 상태 유지, 완료 후 ACK 및 읽기 변환. | 동기/비동기 클록 관계와 endian 계약을 확정한 통합 검증 필요. |
| 38 | 마이크로코드 시퀀서 | 원문 POP 지연은 3클록인데 테스트는 POP 적용 후 2개 상승 에지에서 확인한다. 테스트 안에서 동일 클록을 반복 시작하고 PRST를 삽입하므로 스택/PC 초기화 시점도 주의해야 한다. 공식 POP 기대값 8과 실제 0 불일치가 남았다. | PRST, PC 진행, PUSH, POP 후 3클록 결과를 확인. **모든 opcode/스택 경계 검증은 아님.** | 단일 클록 생성기, 에지 후 안정화, 명시적 PRST/PUSH/POP 시퀀스로 추가 검증 필요. |
| 42 | 데시메이터 | 원문 예제 `{10,20,30,40,50,60,70,80}` → `{10,50}`는 MSB 쪽부터 선택한다. 공식 모델은 입력 리스트를 뒤집은 후 DEC_FACTOR 간격으로 선택해 반대 방향을 사용한다. | 원문 예제 그대로, 음수 입력의 signed peak. | MSB/LSB 기준 합의 또는 두 동작을 명시한 parameter 필요. |
| 43 | 뉴로모픽 배열 | 원문 Hierarchy는 뉴런 출력이 다음 뉴런으로 순차 연결된다고 명시한다. 공식 테스트는 NEURONS단 전달 시간을 기다리지 않고 입력에 가까운 값을 기대한다. | NEURONS=4 cascade, 40클록의 입력 변화 및 control=0 유지. | 병렬 입력/직렬 cascade 중 의도 확정 필요. |
| 46 | 클록 지터 검출 | 원문은 기준값에서 **1클록보다 큰** 편차를 오류로 정의한다. 공식 모델은 `counter != JITTER_THRESHOLD`로 모든 편차를 오류로 판단하며 초기 구간 억제 조건도 별도 적용한다. | 정상 5클록, 허용 6클록, 오류 8클록 및 1클록 오류 펄스. | 허용 오차와 초기 측정 구간을 동일하게 정의한 검증 필요. |

## 근거 파일

모든 경로는 저장소 루트 기준이다.

- 원문: `selections/next_50/problems/`의 동일 번호 `problem.md`.
- SIPO: `work_next50_batch02_first/cvdp_copilot_serial_in_parallel_out/harness/14/src/test_sipo.py`, 특히 루프의 `parallel_out_1` 캡처와 이후 `compute_expected_crc` 호출.
- 핑퐁: `work_next50_r5/cvdp_copilot_ping_pong_buffer/harness/1/src/test_ping_pong_buffer.py`의 `async_reset_test`.
- WB/AHB: `work_next50_batch03_first_valid/cvdp_copilot_wb2ahb/harness/1/src/test_wishbone_to_ahb_bridge.py`.
- 시퀀서: `work_next50_r5/cvdp_copilot_microcode_sequencer/harness/1/src/test_microcode_sequencer.py`의 `test_pop_pc_instruction`.
- 데시메이터: `work_next50_batch05_first/cvdp_copilot_configurable_digital_low_pass_filter/harness/4/src/test_advanced_decimator_with_adaptive_peak_detection.py`.
- 뉴런: `work_next50_batch05_first/cvdp_copilot_neuromorphic_array/harness/1/src/test_neuromorphic_array.py`.
- 지터: `work_next50_batch05_first/cvdp_copilot_clock_jitter_detection_module/harness/3/src/test_clock_jitter_detection.py`.
- 자체 진단: `solutions/next_50/diagnostics/run_checks.py`, 개별 `.sv`, `.log`, `results.json`.

진단 재실행: `.venv/bin/python solutions/next_50/diagnostics/run_checks.py` (로컬 Icarus Verilog 사용).
