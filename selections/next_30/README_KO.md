# 다음에 풀 CVDP 30문제

기존에 푼 11문제와 문제 ID가 겹치지 않는 새 30문제입니다. 비상용 non-agentic v1.1.0 문제 은행에서 풀이 범위와 분야 다양성을 기준으로 골랐습니다. Easy 15개 / Medium 15개이며 난이도는 원본 라벨입니다.

**30개 답안 작성 및 공식 평가 완료:** 첫 제출 20/30 통과, 수정 후 26/30 통과, 별도 호환본 2개 포함 28/30 통과. 공식 미통과 2개는 남아 있습니다. [상세 결과](../../solutions/next_30/RESULTS_KO.md).

## 구성

- `selected.jsonl`: 평가용 원본 레코드 30개, 원문과 harness 보존.
- `batch_01.jsonl` ~ `batch_03.jsonl`: 권장 순서로 10문제씩.
- `problems/`: 문제별 원문 및 제공 코드. 정답과 harness 테스트 내용은 문제 설명 파일에 넣지 않음.
- `input_only.jsonl`: 답안 작성용 입력만 담은 파일.
- `manifest.json`: 출처 체크섬, ID, 분류, 상태 기록.

## 풀이 순서

1차 1~10: Easy 10개, 기본 논리와 산술·신호처리·CDC 디버깅.
2차 11~20: Easy 5개 + Medium 5개, 구조 변경에서 통신·버퍼 설계로 확장.
3차 21~30: Medium 10개, 프로세서·패킷·합성 최적화.

| 번호 | 문제 | 난이도 | 작업 | 분야 |
|---|---|---|---|---|
| 1 | [시프트·회전 기능 확장](problems/01_barrel_shifter_0037/problem.md) | easy | 기능·구조 변경 | 비트 연산 |
| 2 | [부호·크기 모드 비교기](problems/02_comparator_0001/problem.md) | easy | 새 설계 | 비교 연산 |
| 3 | [24시간 BCD 시계](problems/03_bcd_counter_0001/problem.md) | easy | 새 설계 | 카운터 |
| 4 | [이진수→BCD 변환](problems/04_binary_to_BCD_0001/problem.md) | easy | 코드 완성 | 수 표현 |
| 5 | [복소수 곱셈기](problems/05_complex_multiplier_0001/problem.md) | easy | 새 설계 | 산술 연산 |
| 6 | [해밍 코드 수신기](problems/06_hamming_code_tx_and_rx_0003/problem.md) | easy | 새 설계 | 오류 정정 |
| 7 | [이동평균 필터](problems/07_moving_average_0001/problem.md) | easy | 새 설계 | 신호처리 |
| 8 | [클록 분주기](problems/08_clock_divider_0003/problem.md) | easy | 새 설계 | 클록 제어 |
| 9 | [CDC 펄스 동기화 버그 수정](problems/09_cdc_pulse_synchronizer_0004/problem.md) | easy | 버그 수정 | 클록 도메인 교차 |
| 10 | [반복 나눗셈기 버그 수정](problems/10_radix2_div_0001/problem.md) | easy | 버그 수정 | 산술 디버깅 |
| 11 | [곱셈기 순차회로 전환](problems/11_binary_multiplier_0012/problem.md) | easy | 기능·구조 변경 | 구조 변경 |
| 12 | [맨체스터 인코더 래치 수정](problems/12_manchester_enc_0005/problem.md) | easy | 버그 수정 | 래치 제거 |
| 13 | [이미지 회전 RTL Lint 수정](problems/13_image_rotate_0014/problem.md) | easy | Lint/최적화 | 코드 정비 |
| 14 | [GF 곱셈기 8비트 확장](problems/14_gf_multiplier_0005/problem.md) | easy | 기능·구조 변경 | 유한체 연산 |
| 15 | [2단 파이프라인 MAC](problems/15_pipeline_mac_0017/problem.md) | easy | 코드 완성 | 파이프라인 |
| 16 | [SPI 송신 상태 기계](problems/16_simple_spi_0001/problem.md) | medium | 코드 완성 | 직렬 통신 |
| 17 | [파이프라인 Skid 버퍼](problems/17_skid_buffer_0001/problem.md) | medium | 코드 완성 | 흐름 제어 |
| 18 | [비동기 FIFO](problems/18_fifo_async_0001/problem.md) | medium | 새 설계 | 버퍼·CDC |
| 19 | [APB GPIO 제어기](problems/19_apb_gpio_0001/problem.md) | medium | 새 설계 | 버스 주변장치 |
| 20 | [중재기 우선순위·타임아웃 확장](problems/20_round_robin_arbiter_0005/problem.md) | medium | 기능·구조 변경 | 자원 중재 |
| 21 | [트리 기반 pseudo-LRU](problems/21_cache_lru_0019/problem.md) | medium | 코드 완성 | 캐시 교체 정책 |
| 22 | [Load/Store 유닛](problems/22_load_store_unit_0001/problem.md) | medium | 새 설계 | 프로세서 |
| 23 | [동적 우선순위 인터럽트 제어기](problems/23_interrupt_controller_0017/problem.md) | medium | 코드 완성 | 인터럽트 |
| 24 | [이더넷 패킷 파서](problems/24_ethernet_packet_parser_0001/problem.md) | medium | 새 설계 | 패킷 처리 |
| 25 | [16QAM 매퍼와 보간](problems/25_16qam_mapper_0001/problem.md) | medium | 새 설계 | 디지털 통신 |
| 26 | [복원 나눗셈기 설계](problems/26_restoring_division_0001/problem.md) | medium | 새 설계 | 반복 알고리즘 |
| 27 | [영상 변환 FIFO 버그 수정](problems/27_rgb2ycbcr_0001/problem.md) | medium | 버그 수정 | 영상 디버깅 |
| 28 | [버블 정렬→삽입 정렬 전환](problems/28_sorter_0003/problem.md) | medium | 기능·구조 변경 | 정렬 알고리즘 |
| 29 | [팬 제어기 Lint 수정](problems/29_fan_controller_0005/problem.md) | medium | Lint/최적화 | 코드 정비 |
| 30 | [조합논리 면적 최적화](problems/30_scrambler_0024/problem.md) | medium | Lint/최적화 | 합성 최적화 |

## 평가 준비

문제별 첫 답안을 고정한 뒤 평가하고, 테스트를 본 이후의 수정본은 별도로 기록합니다. 자판기 문제처럼 사양과 테스트가 어긋날 경우 출력 시점·유지 기간의 가정을 먼저 기록합니다.

응답 파일은 한 줄에 `{"id":"문제 ID","completion":"작성한 RTL 원문"}` 형식입니다. 응답 작성 후 다음 명령으로 1차 묶음을 평가할 수 있습니다.

```bash
cd /Users/bagjunbeom/Downloads/CVDP
./scripts/cvdp start
./scripts/cvdp benchmark -f selections/next_30/batch_01.jsonl -l -m local_import --prompts-responses-file /절대경로/responses.jsonl -p "work_next30_batch01_$(date +%Y%m%d_%H%M%S)"
```

이 선택은 다양성 중심의 목적 표본으로 전체 CVDP 성능 추정용 무작위 표본이 아닙니다. 원본 데이터의 표기와 사양을 그대로 보존했습니다.
