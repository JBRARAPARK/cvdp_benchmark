# CVDP 대표 10문제 풀이 결과

> 최신 후속 결과: [즉시 오류 + 공식 호환 자판기](comb_compatible/README_KO.md)가 공식 내부 테스트 10/10 및 즉시 출력 검사 15개를 통과했습니다. 오류 유지 기간과 거스름돈 타이밍의 사양 차이는 링크에 명시했습니다.


> 후속 수정: [사양 기준 자판기 수정본](spec_fixed/README_KO.md)을 추가했습니다. 독립 테스트 32개 시나리오·156검사는 통과하지만 원본 공식 테스트는 출력/오류 타이밍 차이로 실패합니다. 아래 10/10은 이전 `revised/`의 공식 테스트 호환 답안 결과이며, 새 수정본의 결과가 아닙니다.


첫 제출: **9/10 문제**, 공식 harness 서비스 **11/12 통과**. 자판기 1회 수정 후: **10/10 문제**, **12/12 서비스 통과**. 서비스 내부의 pytest/cocotb 테스트 수와는 구별합니다.

현재 대화의 Codex가 문제와 제공 RTL을 읽고 직접 답안을 작성했습니다. 별도 외부 LLM API 호출은 없으며 local_import는 작성한 RTL을 전달하는 공식 어댑터입니다.

첫 답안 작성에는 문제의 input만 사용했습니다. 자판기 수정에는 첫 실행 로그와 공식 테스트 코드를 확인했으므로 수정 후 결과는 독립적인 첫 시도 성능 점수가 아닙니다.

| 문제 | 첫 제출 | 최종 | 답안 | 최종 공식 로그 |
|---|---|---|---|---|
| 1. 우선순위 인코더 | 통과 | 통과 | [RTL](revised/cvdp_copilot_8x3_priority_encoder_0001.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_8x3_priority_encoder/reports/1.txt) |
| 2. 자판기 | 실패 | 통과 | [RTL](revised/cvdp_copilot_vending_machine_0001.sv) | [서비스 1](../evaluation_evidence/work_rep10_vending_r1/cvdp_copilot_vending_machine/reports/1.txt) |
| 3. FIR 필터 | 통과 | 통과 | [RTL](revised/cvdp_copilot_FIR_0001.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_FIR/reports/1.txt) |
| 4. AXI4-Lite 레지스터 | 통과 | 통과 | [RTL](revised/cvdp_copilot_axi_register_0001.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_axi_register/reports/1.txt) |
| 5. 비동기 클록 전환 | 통과 | 통과 | [RTL](revised/cvdp_copilot_GFCM_0003.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_GFCM/reports/3.txt) |
| 6. MSHR | 통과 | 통과 | [RTL](revised/cvdp_copilot_MSHR_0001.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_MSHR/reports/1.txt) |
| 7. RS232/UART | 통과 | 통과 | [RTL](revised/cvdp_copilot_rs_232_0001.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_rs_232/reports/1.txt) |
| 8. Brent–Kung 가산기 | 통과 | 통과 | [RTL](revised/cvdp_copilot_32_bit_Brent_Kung_PP_adder_0001.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_32_bit_Brent_Kung_PP_adder/reports/1.txt) |
| 9. 오디오 Lint | 통과 | 통과 | [RTL](revised/cvdp_copilot_sigma_delta_audio_0007.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_sigma_delta_audio/reports/7_lint.txt) · [서비스 2](../evaluation_evidence/work_rep10_first/cvdp_copilot_sigma_delta_audio/reports/7_sanity.txt) |
| 10. VGA 면적 최적화 | 통과 | 통과 | [RTL](revised/cvdp_copilot_vga_controller_0026.sv) | [서비스 1](../evaluation_evidence/work_rep10_first/cvdp_copilot_vga_controller/reports/26_sanity.txt) · [서비스 2](../evaluation_evidence/work_rep10_first/cvdp_copilot_vga_controller/reports/26_synth.txt) |

## 풀이 및 수정 내용

[문제별 풀이와 가정](NOTES_KO.md)을 참고하세요. first/에 최초 답안, revised/에 최종 답안 10개를 보존했습니다. 자판기만 수정했고 다른 9개는 최초 답안과 동일합니다.

자판기 수정: 상품 ID를 거래 완료 후에도 유지하고, 거스름돈 출력 전 대기 상태를 추가했습니다. 선택되지 않은/유효하지 않은 상품에 동전이 투입되면 오류와 반환을 처리하도록 변경했습니다. 가격 5/10/15/20 가정은 테스트와 일치했습니다.

주의: 자판기 원문은 잘못된 상품 ID에 즉시 오류, 배출 다음 클록에 거스름돈 반환을 설명하지만, 공식 테스트의 관측 타이밍에 맞춘 최종 답안은 추가 대기 상태 및 동전 투입 시 오류 처리를 사용합니다. 따라서 공식 테스트 통과와 원문의 모든 문장에 대한 엄밀한 충족은 구별해야 합니다.

## VGA 합성 결과

- 셀: 421 → 197, **53.21% 감소** (요구 49% 이상).
- wire: 363 → 159, **56.20% 감소** (요구 52% 이상).
- 공식 기능 테스트와 합성 테스트 모두 통과. 이는 제공 테스트의 검증이며 별도 formal equivalence 증명은 수행하지 않았습니다.

## 결과 해석

- 10개는 다양성 중심의 소규모 표본으로 전체 CVDP 성능을 추정하지 않습니다.
- 디지털 테스트만으로 실제 실리콘의 메타안정성·글리치 안전성을 보증하지 않습니다.
- 일부 문제의 모호한 사양과 첫 답안 가정은 NOTES_KO.md에 기록했습니다.
- 로그에 API 키 없는 주관적 채점 모델 초기화 오류가 출력됐으나, 여기에 보고한 점수는 공식 시뮬레이션·Lint·합성 서비스 결과입니다. 주관적 LLM 평가는 포함하지 않습니다.

## 다시 평가하기

```bash
cd /Users/bagjunbeom/Downloads/CVDP
./scripts/cvdp benchmark -f selections/representative_10/selected.jsonl -l -m local_import --prompts-responses-file solutions/representative_10/revised/responses.jsonl -p "work_rep10_final_$(date +%Y%m%d_%H%M%S)"
```
