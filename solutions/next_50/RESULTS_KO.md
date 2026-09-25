# 다음 50문제 RTL 풀이 결과

2026-09-25 후속: [미통과 7개 한 차례 재풀이](retry_20260925/README_KO.md). 호환 설정 4개 PASS / 3개 FAIL이며 기존 43/50 집계는 유지한다.

**50개 구현·공식 평가 완료. 첫 시도 23/50 → 수정 후 통합 재평가 43/50 통과.**
공식 미통과 7개는 별도 진단 7개를 통과했지만 공식 통과 수에 포함하지 않는다. 모든 테스트 결과가 0인 문제만 PASS로 센다.

- [최종 공식 결과](../evaluation_evidence/work_next50_final/raw_result.json)
- [50개 최종 RTL](final)
- [미통과 원인·진단 범위](FAILURES_KO.md)
- [구현 및 평가 해석 주의점](IMPLEMENTATION_NOTES_KO.md)
- [기계 판독 결과·RTL SHA-256](results.json)
- [수정 이력](attempts.json)

## 묶음별 결과

| 묶음 | 첫 시도 | 최종 공식 |
|---|---:|---:|
| 1 | 8/10 | 10/10 |
| 2 | 3/10 | 9/10 |
| 3 | 6/10 | 8/10 |
| 4 | 2/10 | 9/10 |
| 5 | 4/10 | 7/10 |

## 전체 50개

| 번호 | 문제 | 첫 시도 | 최종 공식 | RTL |
|---:|---|---|---|---|
| 1 | BCD 가산기 | PASS | PASS | [bcd_adder_0001](final/cvdp_copilot_bcd_adder_0001.sv) |
| 2 | 매개변수화 반올림 회로 | FAIL | PASS | [rounding_0001](final/cvdp_copilot_rounding_0001.sv) |
| 3 | 벡터 내적 계산기 | PASS | PASS | [dot_product_0002](final/cvdp_copilot_dot_product_0002.sv) |
| 4 | 순차 Booth 곱셈기 수정 | PASS | PASS | [modified_booth_mul_0002](final/cvdp_copilot_modified_booth_mul_0002.sv) |
| 5 | Montgomery reduction 수정 | PASS | PASS | [montgomery_0001](final/cvdp_copilot_montgomery_0001.sv) |
| 6 | 제곱근 회로 순차화 | PASS | PASS | [square_root_0003](final/cvdp_copilot_square_root_0003.sv) |
| 7 | 행렬 곱셈기 순차화 | PASS | PASS | [matrix_multiplier_0007](final/cvdp_copilot_matrix_multiplier_0007.sv) |
| 8 | Kogge–Stone 가산기 수정 | PASS | PASS | [kogge_stone_adder_0007](final/cvdp_copilot_kogge_stone_adder_0007.sv) |
| 9 | 부호 있는 가감산기 | PASS | PASS | [signed_adder_0001](final/cvdp_copilot_signed_adder_0001.sv) |
| 10 | 병렬 가산 트리 | FAIL | PASS | [cascaded_adder_0025](final/cvdp_copilot_cascaded_adder_0025.sv) |
| 11 | 64b/66b 인코더 | PASS | PASS | [64b66b_encoder_0001](final/cvdp_copilot_64b66b_encoder_0001.sv) |
| 12 | 64b/66b 복합 모드 디코더 | FAIL | PASS | [64b66b_decoder_0011](final/cvdp_copilot_64b66b_decoder_0011.sv) |
| 13 | 컨볼루션 인코더 | FAIL | PASS | [convolutional_encoder_0001](final/cvdp_copilot_convolutional_encoder_0001.sv) |
| 14 | Reed–Solomon 인코더 | FAIL | PASS | [reed_solomon_encoder_and_decoder_0005](final/cvdp_copilot_reed_solomon_encoder_and_decoder_0005.sv) |
| 15 | Huffman 인코더 | FAIL | PASS | [huffman_0001](final/cvdp_copilot_huffman_0001.sv) |
| 16 | PRBS 생성기·검사기 | FAIL | PASS | [prbs_gen_0003](final/cvdp_copilot_prbs_gen_0003.sv) |
| 17 | SIPO에 CRC 추가 | FAIL | FAIL · 별도 진단만 PASS | [serial_in_parallel_out_0014](final/cvdp_copilot_serial_in_parallel_out_0014.sv) |
| 18 | Sony IR 수신기 | FAIL | PASS | [ir_receiver_0005](final/cvdp_copilot_ir_receiver_0005.sv) |
| 19 | Data Bus Inversion 인코더 | PASS | PASS | [dbi_0001](final/cvdp_copilot_dbi_0001.sv) |
| 20 | 패킷 송수신 제어기 | PASS | PASS | [packet_controller_0001](final/cvdp_copilot_packet_controller_0001.sv) |
| 21 | 32→128비트 폭 변환기 | PASS | PASS | [data_width_converter_0003](final/cvdp_copilot_data_width_converter_0003.sv) |
| 22 | 핑퐁 버퍼 | FAIL | FAIL · 별도 진단만 PASS | [ping_pong_buffer_0001](final/cvdp_copilot_ping_pong_buffer_0001.sv) |
| 23 | 다단 비트 동기화기 | PASS | PASS | [bit_synchronizer_0001](final/cvdp_copilot_bit_synchronizer_0001.sv) |
| 24 | MUX 기반 CDC 수정 | PASS | PASS | [mux_synch_0011](final/cvdp_copilot_mux_synch_0011.sv) |
| 25 | 동기 LIFO | PASS | PASS | [sync_lifo_0001](final/cvdp_copilot_sync_lifo_0001.sv) |
| 26 | 4×4 크로스바 스위치 | PASS | PASS | [crossbar_switch_0001](final/cvdp_copilot_crossbar_switch_0001.sv) |
| 27 | AXI Stream 멀티플렉서 | PASS | PASS | [axis_mux_0001](final/cvdp_copilot_axis_mux_0001.sv) |
| 28 | AXI Stream 결합기 | FAIL | PASS | [axis_joiner_0001](final/cvdp_copilot_axis_joiner_0001.sv) |
| 29 | AXI4-Lite TAP | FAIL | PASS | [axi_tap_0001](final/cvdp_copilot_axi_tap_0001.sv) |
| 30 | Wishbone→AHB 브리지 | FAIL | FAIL · 별도 진단만 PASS | [wb2ahb_0001](final/cvdp_copilot_wb2ahb_0001.sv) |
| 31 | CPU 성능 카운터 | FAIL | PASS | [perf_counters_0001](final/cvdp_copilot_perf_counters_0001.sv) |
| 32 | 쓰기 병합 버퍼 | FAIL | PASS | [write_buffer_merge_0001](final/cvdp_copilot_write_buffer_merge_0001.sv) |
| 33 | 엄격한 LRU 교체 정책 | PASS | PASS | [cache_lru_0008](final/cvdp_copilot_cache_lru_0008.sv) |
| 34 | 가상→물리 주소 TLB | FAIL | PASS | [virtual2physical_tlb_0001](final/cvdp_copilot_virtual2physical_tlb_0001.sv) |
| 35 | 명령어 캐시 제어기 | FAIL | PASS | [icache_controller_0001](final/cvdp_copilot_icache_controller_0001.sv) |
| 36 | RISC-V 정적 분기 예측기 | FAIL | PASS | [static_branch_predict_0001](final/cvdp_copilot_static_branch_predict_0001.sv) |
| 37 | 자원 할당기 | PASS | PASS | [mem_allocator_0001](final/cvdp_copilot_mem_allocator_0001.sv) |
| 38 | 마이크로코드 시퀀서 | FAIL | FAIL · 별도 진단만 PASS | [microcode_sequencer_0001](final/cvdp_copilot_microcode_sequencer_0001.sv) |
| 39 | 레지스터 파일 BIST 확장 | FAIL | PASS | [register_file_2R1W_0006](final/cvdp_copilot_register_file_2R1W_0006.sv) |
| 40 | APB 분기 이력 레지스터 | FAIL | PASS | [apb_history_shift_register_0001](final/cvdp_copilot_apb_history_shift_register_0001.sv) |
| 41 | 설정 가능한 저역통과 필터 | PASS | PASS | [configurable_digital_low_pass_filter_0001](final/cvdp_copilot_configurable_digital_low_pass_filter_0001.sv) |
| 42 | 데시메이터·적응형 피크 검출 | FAIL | FAIL · 별도 진단만 PASS | [configurable_digital_low_pass_filter_0004](final/cvdp_copilot_configurable_digital_low_pass_filter_0004.sv) |
| 43 | 뉴로모픽 배열 | FAIL | FAIL · 별도 진단만 PASS | [neuromorphic_array_0001](final/cvdp_copilot_neuromorphic_array_0001.sv) |
| 44 | Sobel 필터 수정 | PASS | PASS | [sobel_filter_0011](final/cvdp_copilot_sobel_filter_0011.sv) |
| 45 | 영상 라인 버퍼 수정 | PASS | PASS | [line_buffer_0003](final/cvdp_copilot_line_buffer_0003.sv) |
| 46 | 클록 지터 검출기 | FAIL | FAIL · 별도 진단만 PASS | [clock_jitter_detection_module_0003](final/cvdp_copilot_clock_jitter_detection_module_0003.sv) |
| 47 | 온도 제어 FSM | FAIL | PASS | [thermostat_0001](final/cvdp_copilot_thermostat_0001.sv) |
| 48 | 경량 타이머·카운터 | FAIL | PASS | [ttc_lite_0001](final/cvdp_copilot_ttc_lite_0001.sv) |
| 49 | AXI 제어 ALU 수정 | FAIL | PASS | [axi_alu_0001](final/cvdp_copilot_axi_alu_0001.sv) |
| 50 | 알파 블렌딩 RTL Lint 수정 | PASS | PASS | [alphablending_0003](final/cvdp_copilot_alphablending_0003.sv) |

## 재실행

```sh
./scripts/cvdp benchmark -f solutions/next_50/final/dataset.jsonl -l -m local_import \
  --prompts-responses-file solutions/next_50/final/responses.jsonl -p work_next50_recheck
```

작업 디렉터리는 `/Users/bagjunbeom/Downloads/CVDP`이다. Docker/Colima 실행 환경이 필요하다. 일부 테스트는 무작위 자극·파라미터를 사용하므로 재실행 시 샘플이 달라진다.

첫 답안은 원문/제공 코드로 작성했고, 수정본은 실패 후 테스트를 확인했다. 정답 RTL을 복사한 결과가 아니다. 원본 데이터셋 SHA-256은 선정 당시와 동일하다. 원본 harness는 변경하지 않았다. API 키가 없는 주관 평가 점수는 주장하지 않는다.
