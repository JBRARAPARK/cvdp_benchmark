# 다음 단계 CVDP 50문제

**50문제 구현·평가 완료 — 첫 시도 23/50, 수정 후 공식 43/50 통과.**

[전체 결과와 남은 문제](../../solutions/next_50/RESULTS_KO.md)

출처: [비상용 Non-agentic RTL 생성 302문제](../../datasets/cvdp_v1.1.0_nonagentic_code_generation_no_commercial.jsonl). 기존 41개 시도 ID를 제외했습니다. 공식 실패 문제도 재선정하지 않았습니다. 기존 ID 중 원본 302개에 포함되는 것은 40개라서 후보는 262개이며, 여기서 50개를 골랐습니다. 같은 설계 계열이라도 다른 요구를 다루는 문제는 포함됩니다.

각 10문제씩 5개 묶음으로 풀이했습니다. 1차 답안은 input_only 또는 문제별 원문만으로 작성했고, 실패 후 테스트를 확인한 수정본은 따로 보관했습니다. Easy/Medium은 원본 라벨이며 예상 소요시간을 뜻하지 않습니다.

## 파일 구성

- `selected.jsonl`: 원본 레코드 50개. 정답 필드와 공식 harness 포함, 평가용.
- `input_only.jsonl`: ID·분류·입력만 포함. 첫 풀이용.
- `batch_01.jsonl` ~ `batch_05.jsonl`: 10문제 단위 공식 평가 입력.
- `problems/`: 원문과 제공 코드. 정답·테스트 본문 제외.
- `manifest.json`: 출처, 제외 목록, 선정 이유, 실행 환경 정적 점검 기록.

## 선정 목록

### 1차: 산술·수치 연산 — Easy 7 / Medium 3

| 번호 | 문제 | 난이도 | 주요 학습·검증 포인트 |
|---:|---|---|---|
| 1 | [BCD 가산기](problems/01_bcd_adder_0001/problem.md) | easy | 십진 보정과 자리올림 |
| 2 | [매개변수화 반올림 회로](problems/02_rounding_0001/problem.md) | easy | 반올림 모드와 경계값 |
| 3 | [벡터 내적 계산기](problems/03_dot_product_0002/problem.md) | easy | 곱셈·누산과 출력 폭 |
| 4 | [순차 Booth 곱셈기 수정](problems/04_modified_booth_mul_0002/problem.md) | easy | 부호 확장과 반복 연산 |
| 5 | [Montgomery reduction 수정](problems/05_montgomery_0001/problem.md) | easy | 모듈러 연산과 비트 폭 |
| 6 | [제곱근 회로 순차화](problems/06_square_root_0003/problem.md) | easy | 조합 알고리즘의 다중 사이클 전환 |
| 7 | [행렬 곱셈기 순차화](problems/07_matrix_multiplier_0007/problem.md) | easy | 행렬 인덱스와 완료 제어 |
| 8 | [Kogge–Stone 가산기 수정](problems/08_kogge_stone_adder_0007/problem.md) | medium | 프리픽스 캐리 연결 |
| 9 | [부호 있는 가감산기](problems/09_signed_adder_0001/problem.md) | medium | 부호·오버플로 처리 |
| 10 | [병렬 가산 트리](problems/10_cascaded_adder_0025/problem.md) | medium | 가산 구조와 병렬 처리 |

### 2차: 통신·부호화 — Easy 5 / Medium 5

| 번호 | 문제 | 난이도 | 주요 학습·검증 포인트 |
|---:|---|---|---|
| 11 | [64b/66b 인코더](problems/11_64b66b_encoder_0001/problem.md) | easy | 데이터와 동기 헤더 |
| 12 | [64b/66b 복합 모드 디코더](problems/12_64b66b_decoder_0011/problem.md) | medium | 데이터·제어·혼합 모드 |
| 13 | [컨볼루션 인코더](problems/13_convolutional_encoder_0001/problem.md) | easy | 상태와 생성 다항식 |
| 14 | [Reed–Solomon 인코더](problems/14_reed_solomon_encoder_and_decoder_0005/problem.md) | easy | 유한체 기반 오류 정정 부호 |
| 15 | [Huffman 인코더](problems/15_huffman_0001/problem.md) | easy | 부호 테이블과 입력 우선순위 |
| 16 | [PRBS 생성기·검사기](problems/16_prbs_gen_0003/problem.md) | medium | 의사난수 패턴 생성과 오류 검출 |
| 17 | [SIPO에 CRC 추가](problems/17_serial_in_parallel_out_0014/problem.md) | medium | 직렬 수신과 CRC 누적 |
| 18 | [Sony IR 수신기](problems/18_ir_receiver_0005/problem.md) | easy | 펄스 길이와 프레임 해석 |
| 19 | [Data Bus Inversion 인코더](problems/19_dbi_0001/problem.md) | medium | 비트 반전 판단과 제어 신호 |
| 20 | [패킷 송수신 제어기](problems/20_packet_controller_0001/problem.md) | medium | 패킷 FSM과 데이터 흐름 |

### 3차: 버퍼·CDC·버스 — Easy 3 / Medium 7

| 번호 | 문제 | 난이도 | 주요 학습·검증 포인트 |
|---:|---|---|---|
| 21 | [32→128비트 폭 변환기](problems/21_data_width_converter_0003/problem.md) | easy | 데이터 조립과 valid 타이밍 |
| 22 | [핑퐁 버퍼](problems/22_ping_pong_buffer_0001/problem.md) | easy | 이중 버퍼와 읽기·쓰기 전환 |
| 23 | [다단 비트 동기화기](problems/23_bit_synchronizer_0001/problem.md) | easy | 클록 도메인 간 제어 신호 전달 |
| 24 | [MUX 기반 CDC 수정](problems/24_mux_synch_0011/problem.md) | medium | 제어 펄스와 데이터 정합 |
| 25 | [동기 LIFO](problems/25_sync_lifo_0001/problem.md) | medium | push·pop과 full·empty |
| 26 | [4×4 크로스바 스위치](problems/26_crossbar_switch_0001/problem.md) | medium | 입출력 라우팅 |
| 27 | [AXI Stream 멀티플렉서](problems/27_axis_mux_0001/problem.md) | medium | 선택·프레임·역압 처리 |
| 28 | [AXI Stream 결합기](problems/28_axis_joiner_0001/problem.md) | medium | 다중 입력과 출력 흐름 제어 |
| 29 | [AXI4-Lite TAP](problems/29_axi_tap_0001/problem.md) | medium | 독립 채널의 트랜잭션 처리 |
| 30 | [Wishbone→AHB 브리지](problems/30_wb2ahb_0001/problem.md) | medium | 버스 프로토콜 변환 |

### 4차: CPU·캐시·메모리 — Easy 2 / Medium 8

| 번호 | 문제 | 난이도 | 주요 학습·검증 포인트 |
|---:|---|---|---|
| 31 | [CPU 성능 카운터](problems/31_perf_counters_0001/problem.md) | easy | 이벤트 집계와 소프트웨어 리셋 |
| 32 | [쓰기 병합 버퍼](problems/32_write_buffer_merge_0001/problem.md) | easy | 주소·바이트 단위 병합 |
| 33 | [엄격한 LRU 교체 정책](problems/33_cache_lru_0008/problem.md) | medium | 기존 pseudo-LRU와 다른 교체 정책 |
| 34 | [가상→물리 주소 TLB](problems/34_virtual2physical_tlb_0001/problem.md) | medium | 태그 검색과 주소 변환 |
| 35 | [명령어 캐시 제어기](problems/35_icache_controller_0001/problem.md) | medium | 히트·미스·메모리 요청 |
| 36 | [RISC-V 정적 분기 예측기](problems/36_static_branch_predict_0001/problem.md) | medium | 명령어 디코딩과 분기 판단 |
| 37 | [자원 할당기](problems/37_mem_allocator_0001/problem.md) | medium | 빈 슬롯 탐색과 반환 |
| 38 | [마이크로코드 시퀀서](problems/38_microcode_sequencer_0001/problem.md) | medium | 명령어와 제어 주소 생성 |
| 39 | [레지스터 파일 BIST 확장](problems/39_register_file_2R1W_0006/problem.md) | medium | 내장 자기진단과 정상 접근 |
| 40 | [APB 분기 이력 레지스터](problems/40_apb_history_shift_register_0001/problem.md) | medium | 버스 접근과 이력 갱신 |

### 5차: 신호처리·영상·제어 — Easy 3 / Medium 7

| 번호 | 문제 | 난이도 | 주요 학습·검증 포인트 |
|---:|---|---|---|
| 41 | [설정 가능한 저역통과 필터](problems/41_configurable_digital_low_pass_filter_0001/problem.md) | medium | 고정소수점과 샘플 상태 |
| 42 | [데시메이터·적응형 피크 검출](problems/42_configurable_digital_low_pass_filter_0004/problem.md) | medium | 샘플 간격과 검출 상태 |
| 43 | [뉴로모픽 배열](problems/43_neuromorphic_array_0001/problem.md) | medium | 배열 연산과 제어 |
| 44 | [Sobel 필터 수정](problems/44_sobel_filter_0011/problem.md) | easy | 영상 경계 연산 |
| 45 | [영상 라인 버퍼 수정](problems/45_line_buffer_0003/problem.md) | medium | 픽셀 윈도와 인덱스 |
| 46 | [클록 지터 검출기](problems/46_clock_jitter_detection_module_0003/problem.md) | easy | 주기 측정과 임계 비교 |
| 47 | [온도 제어 FSM](problems/47_thermostat_0001/problem.md) | medium | 가열·냉각 상태 전이 |
| 48 | [경량 타이머·카운터](problems/48_ttc_lite_0001/problem.md) | medium | 설정 가능한 계수와 이벤트 |
| 49 | [AXI 제어 ALU 수정](problems/49_axi_alu_0001/problem.md) | medium | 버스 설정과 산술·논리 연산 제어 |
| 50 | [알파 블렌딩 RTL Lint 수정](problems/50_alphablending_0003/problem.md) | easy | case 중복·다중 구동·순차 할당 점검 |

## 평가 준비 상태

50개 모두 원본 레코드와 compose 설정을 확인했고, 선언된 이미지는 `__OSS_SIM_IMAGE__`입니다. 현재 Docker 환경에서 실제 harness를 실행한 것은 아니므로 실행 가능성·테스트 적합성·통과 여부는 미확인입니다. 일부 문제는 동일 계열의 다른 과제로, 예를 들어 기존 tree pseudo-LRU와 이번 strict LRU는 서로 다른 정책입니다.

기존 SPI·인터럽트에서 확인한 것처럼, 포트명·reset 극성·clock edge·valid/ready 계약·매개변수 기본값을 구현 전에 명시하고 공식 실패와 진단 검증을 별도로 기록합니다.
