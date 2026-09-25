# 새 30문제 풀이 및 평가 결과

**후속 수정 완료:** 남은 2문제의 RTL을 수정하고 독립·진단 테스트를 통과했습니다. 원본 공식 테스트는 계속 미통과입니다. [최신 수정 및 검증 결과](final_two/README_KO.md). 아래 내용은 최초 30문제 평가 당시의 기록입니다.

30문제 모두 RTL 답안을 직접 작성하고 원본 공식 harness로 평가했다. 첫 제출 **20/30 통과**, 테스트 확인 후 수정한 결과 **26/30 통과**, 원문과 차이가 있는 별도 호환본 2개를 포함하면 **28/30 통과**다. SPI와 인터럽트 컨트롤러는 공식 미통과 상태다. 30/30 해결로 해석하면 안 된다.

기존 11개와 겹치지 않으므로 누적 작성·평가 대상은 41개다. 이 문서의 점수는 새 30개만 집계한다. 수정 후 점수는 테스트를 열람한 디버깅 결과이므로 첫 시도 성능과 구분한다. 원본 데이터셋이나 공식 테스트를 변경하지 않았다. local_import는 이 세션에서 작성한 답안을 제출하는 방식이며, 외부 모델 API를 호출해 답안을 생성한 것은 아니다. Subjective scoring 모델의 API 키 경고가 있었으므로 주관 평가 점수를 주장하지 않는다.

## 문제별 결과

| 번호 | 문제 | 첫 제출 | 최신 공식 평가 | 파일 |
|---|---|---|---|---|
| 1 | 시프트·회전 기능 확장 | 통과 | 통과 | [RTL](first/cvdp_copilot_barrel_shifter_0037.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_barrel_shifter/reports/37.txt) |
| 2 | 부호·크기 모드 비교기 | 통과 | 통과 | [RTL](first/cvdp_copilot_comparator_0001.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_comparator/reports/1.txt) |
| 3 | 24시간 BCD 시계 | 통과 | 통과 | [RTL](first/cvdp_copilot_bcd_counter_0001.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_bcd_counter/reports/1.txt) |
| 4 | 이진수→BCD 변환 | 통과 | 통과 | [RTL](first/cvdp_copilot_binary_to_BCD_0001.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_binary_to_BCD/reports/1.txt) |
| 5 | 복소수 곱셈기 | 통과 | 통과 | [RTL](first/cvdp_copilot_complex_multiplier_0001.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_complex_multiplier/reports/1.txt) |
| 6 | 해밍 코드 수신기 | 통과 | 통과 | [RTL](first/cvdp_copilot_hamming_code_tx_and_rx_0003.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_hamming_code_tx_and_rx/reports/3.txt) |
| 7 | 이동평균 필터 | 통과 | 통과 | [RTL](first/cvdp_copilot_moving_average_0001.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_moving_average/reports/1.txt) |
| 8 | 클록 분주기 | 통과 | 통과 | [RTL](first/cvdp_copilot_clock_divider_0003.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_clock_divider/reports/3.txt) |
| 9 | CDC 펄스 동기화 버그 수정 | 통과 | 통과 | [RTL](first/cvdp_copilot_cdc_pulse_synchronizer_0004.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_cdc_pulse_synchronizer/reports/4.txt) |
| 10 | 반복 나눗셈기 버그 수정 | 통과 | 통과 | [RTL](first/cvdp_copilot_radix2_div_0001.sv) · [로그](../evaluation_evidence/work_next30_batch01_first/cvdp_copilot_radix2_div/reports/1.txt) |
| 11 | 곱셈기 순차회로 전환 | 통과 | 통과 | [RTL](first/cvdp_copilot_binary_multiplier_0012.sv) · [로그](../evaluation_evidence/work_next30_batch02_first/cvdp_copilot_binary_multiplier/reports/12.txt) |
| 12 | 맨체스터 인코더 래치 수정 | 실패 | 통과 | [RTL](revised/cvdp_copilot_manchester_enc_0005.sv) · [로그](../evaluation_evidence/work_next30_r3/cvdp_copilot_manchester_enc/reports/5.txt) |
| 13 | 이미지 회전 RTL Lint 수정 | 통과 | 통과 | [RTL](first/cvdp_copilot_image_rotate_0014.sv) · [로그](../evaluation_evidence/work_next30_batch02_first/cvdp_copilot_image_rotate/reports/14_lint.txt) |
| 14 | GF 곱셈기 8비트 확장 | 통과 | 통과 | [RTL](first/cvdp_copilot_gf_multiplier_0005.sv) · [로그](../evaluation_evidence/work_next30_batch02_first/cvdp_copilot_gf_multiplier/reports/5.txt) |
| 15 | 2단 파이프라인 MAC | 실패 | 통과 | [RTL](revised/cvdp_copilot_pipeline_mac_0017.sv) · [로그](../evaluation_evidence/work_next30_r1/cvdp_copilot_pipeline_mac/reports/17.txt) |
| 16 | SPI 송신 상태 기계 | 실패 | 미통과 | [RTL](revised/cvdp_copilot_simple_spi_0001.sv) · [로그](../evaluation_evidence/work_next30_r1/cvdp_copilot_simple_spi/reports/1.txt) |
| 17 | 파이프라인 Skid 버퍼 | 실패 | 호환본 통과 | [RTL](harness_compatible/cvdp_copilot_skid_buffer_0001.sv) · [로그](../evaluation_evidence/work_next30_r4/cvdp_copilot_skid_buffer/reports/1.txt) |
| 18 | 비동기 FIFO | 실패 | 통과 | [RTL](revised/cvdp_copilot_fifo_async_0001.sv) · [로그](../evaluation_evidence/work_next30_r3/cvdp_copilot_fifo_async/reports/1.txt) |
| 19 | APB GPIO 제어기 | 실패 | 호환본 통과 | [RTL](harness_compatible/cvdp_copilot_apb_gpio_0001.sv) · [로그](../evaluation_evidence/work_next30_r4/cvdp_copilot_apb_gpio/reports/1.txt) |
| 20 | 중재기 우선순위·타임아웃 확장 | 통과 | 통과 | [RTL](first/cvdp_copilot_round_robin_arbiter_0005.sv) · [로그](../evaluation_evidence/work_next30_batch02_first/cvdp_copilot_round_robin_arbiter/reports/5.txt) |
| 21 | 트리 기반 pseudo-LRU | 실패 | 통과 | [RTL](revised/cvdp_copilot_cache_lru_0019.sv) · [로그](../evaluation_evidence/work_next30_r2/cvdp_copilot_cache_lru/reports/19.txt) |
| 22 | Load/Store 유닛 | 통과 | 통과 | [RTL](first/cvdp_copilot_load_store_unit_0001.sv) · [로그](../evaluation_evidence/work_next30_batch03_first/cvdp_copilot_load_store_unit/reports/1.txt) |
| 23 | 동적 우선순위 인터럽트 제어기 | 실패 | 미통과 | [RTL](first/cvdp_copilot_interrupt_controller_0017.sv) · [로그](../evaluation_evidence/work_next30_batch03_first/cvdp_copilot_interrupt_controller/reports/17.txt) |
| 24 | 이더넷 패킷 파서 | 실패 | 통과 | [RTL](revised/cvdp_copilot_ethernet_packet_parser_0001.sv) · [로그](../evaluation_evidence/work_next30_r2/cvdp_copilot_ethernet_packet_parser/reports/1.txt) |
| 25 | 16QAM 매퍼와 보간 | 통과 | 통과 | [RTL](first/cvdp_copilot_16qam_mapper_0001.sv) · [로그](../evaluation_evidence/work_next30_batch03_first/cvdp_copilot_16qam_mapper/reports/1.txt) |
| 26 | 복원 나눗셈기 설계 | 통과 | 통과 | [RTL](first/cvdp_copilot_restoring_division_0001.sv) · [로그](../evaluation_evidence/work_next30_batch03_first/cvdp_copilot_restoring_division/reports/1.txt) |
| 27 | 영상 변환 FIFO 버그 수정 | 실패 | 통과 | [RTL](revised/cvdp_copilot_rgb2ycbcr_0001.sv) · [로그](../evaluation_evidence/work_next30_r3/cvdp_copilot_rgb2ycbcr/reports/1.txt) |
| 28 | 버블 정렬→삽입 정렬 전환 | 통과 | 통과 | [RTL](first/cvdp_copilot_sorter_0003.sv) · [로그](../evaluation_evidence/work_next30_batch03_first/cvdp_copilot_sorter/reports/3.txt) |
| 29 | 팬 제어기 Lint 수정 | 통과 | 통과 | [RTL](first/cvdp_copilot_fan_controller_0005.sv) · [로그](../evaluation_evidence/work_next30_batch03_first/cvdp_copilot_fan_controller/reports/5_lint.txt) |
| 30 | 조합논리 면적 최적화 | 통과 | 통과 | [RTL](first/cvdp_copilot_scrambler_0024.sv) · [로그](../evaluation_evidence/work_next30_batch03_first/cvdp_copilot_scrambler/reports/24_sanity.txt) |

## 수정해서 통과한 6문제

- **Manchester 인코더:** 첫 제출에 파일 묶음을 JSON 문자열로 넣어 RTL 컴파일 실패. raw RTL로 고친 조합 회로는 테스트가 출력 valid 상승을 이미 지난 뒤 기다려 정지했다. 해당 컨테이너를 종료했으며 결과 137은 통과가 아니다. 원문의 rising-edge 동작 설명에 맞춰 출력 레지스터와 invalid/reset 시 출력 0 처리를 적용해 통과했다. 제공된 조합 회로와는 지연이 달라진다.
- **Pipeline MAC:** 테스트에서 조회하는 `DWIDTH_ACCUMULATOR` 이름을 복구했다. 연산 로직 변경 없이 통과했다.
- **비동기 FIFO:** top 이름 `fifo_async`, 기본 데이터 폭 32, head 데이터를 미리 출력하는 읽기 방식으로 수정했다. 원문은 기본 폭과 읽기 지연을 지정하지 않는다. Gray 포인터와 두 단계 동기화는 유지했다. 기본 테스트 4개 통과. 현재 구조는 2의 거듭제곱 깊이를 전제로 하며 임의 깊이 및 물리적 CDC 검증은 하지 않았다.
- **캐시 PLRU:** recency 비트를 LRU 방향 대신 MRU 방향으로 기록하고 교체 대상을 반대 방향으로 탐색하도록 수정했다.
- **Ethernet 파서:** 원문에서 명시하지 않은 top 이름을 harness가 요구하는 `field_extract`로 맞췄다.
- **RGB→YCbCr:** 테스트가 관찰하는 내부 신호 `empty`, `fifo_read`를 추가했다. FIFO 및 변환 로직은 유지했다.

중간 재평가에서 발생한 문법 오류도 수정했으며, 모든 시도는 `results.json`의 history와 각 평가 디렉터리에 남아 있다.

## 별도 호환본 2문제

- **Skid buffer:** 원문 top 포트는 `data_i`, `valid_i`지만 공식 테스트는 `i_data`, `i_valid`를 사용한다. 포트 이름만 바꾼 호환본으로 통과했다. 원문 인터페이스 답안은 first/revised에 보존했다.
- **APB GPIO:** 극성 0을 active-high, 1을 active-low로 해석하고 edge interrupt를 유지하도록 했다. 테스트는 `INT_STATE` 주소에 write-one-to-clear를 요구하지만 원문 표에는 Read-only로 되어 있다. 따라서 sticky edge와 W1C가 있는 통과 답안을 `harness_compatible`에 따로 보관했다. revised의 극성만 수정한 버전은 별도 재평가하지 않았다.

## 공식 미통과 2문제와 후속 작업

### SPI

첫 실패는 transmit 진입 시 CS가 아직 high인 문제였으며 수정했다. 이후 공식 테스트는 SPI clock 상승 직후 NBA 갱신이 모두 끝나기 전에 카운터를 읽어 16을 관측하고, 15를 기대하며 실패한다. 테스트에는 15번의 SPI 상승만 확인한 뒤 다음 시스템 클록에서 완료를 기대하는 부분도 있다. 이는 현재 16비트 전송 구현과 맞지 않는다.

별도 `validation/spi_16bit_tb.sv`는 각 SPI 상승 후 값을 안정화시킨 뒤 검사하며, 16비트 `0xABCD`, 남은 비트 수, 완료, disable 후 idle을 통과했다. 공식 테스트를 바꾼 결과로 점수를 올리지 않았다. 후속 작업은 SPI 타이밍 요구를 확정하고, 테스트 샘플링 단계 및 마지막 비트 검사를 정정한 별도 진단 평가다. CS 종료 타이밍 등 전체 프로토콜 검증은 아직 남아 있다.

### 인터럽트 컨트롤러

공식 테스트는 pending IRQ가 있는데 valid가 없다는 이유로 실패한다. 테스트 초기화 코드가 `interrupt_mask`를 구동하지 않으며, RTL의 `interrupt_requests & ~interrupt_mask`로 X가 전달될 가능성이 있다. 또한 테스트의 서비스 간격과 starvation 가산·동률 정책을 현재 구현과 맞춰 검토할 필요가 있다. 마스크 미초기화만을 유일한 원인으로 단정하지 않는다.

별도 `validation/interrupt_mask_tb.sv`에서 mask를 명시적으로 구동하면 IRQ 선택, masked 요청의 missed 기록, acknowledge 후 해제는 통과한다. 이 검사는 공식 전체 검증을 대체하지 않는다. 다음 단계는 독립 진단 harness에서 mask 초기화 후 재현하고 남는 FSM 지연·우선순위 차이를 수정하는 것이다. X를 무조건 허용하도록 RTL을 바꾸지는 않았다.

## 평가 자료와 재현

- 최초 답안: `first/`와 `batch_01_responses.jsonl` ~ `batch_03_responses.jsonl`.
- 수정 제출: `revised/r1_*`, `r2_*`, `r3_*` JSONL. 호환 제출: `harness_compatible/r4_*`.
- 상세 결과: `results.json`. 각 history에는 실행 폴더와 공식 로그 경로가 있다.
- 보조 검증 로그: `logs/next30-supplemental.log` (프로젝트 루트 기준).
- Scrambler는 기능 테스트 및 공식 합성 평가 통과. 해당 합성 보고서의 wire 수는 771→2, 99.74% 감소다. 이는 그 보고서의 지표이며 실제 칩 면적 수치가 아니다.

공식 평가 재현 예시 (프로젝트 루트에서 실행; 실행 폴더는 새 이름 사용):

```sh
./scripts/cvdp benchmark -f solutions/next_30/revised/r3_dataset.jsonl -l -m local_import --prompts-responses-file solutions/next_30/revised/r3_responses.jsonl -p work_next30_r3_repeat
```

테스트 통과는 제공된 테스트 범위의 결과다. 모든 매개변수 조합, 합성·타이밍 및 실제 하드웨어 동작을 보증하지 않는다.
