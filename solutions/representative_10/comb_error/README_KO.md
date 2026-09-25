# 상품 ID 오류의 조합논리 즉시 표시

`vending_machine.sv`는 spec_fixed 회로에 즉시 오류 경로를 추가한 별도 버전입니다.

```systemverilog
assign error = !rst && (error_q ||
               ((state == ITEM_SELECTION) && !valid_item));
```

- 이미 ITEM_SELECTION 상태이면 ID 0/5/6/7 입력 변화가 클록을 기다리지 않고 error에 반영됩니다. 실제 하드웨어에서는 비교기와 게이트 전파 지연이 존재합니다.
- IDLE에서 사용하지 않는 ID 값은 오류를 발생시키지 않습니다. 선택 상태 진입 자체는 여전히 동기식입니다.
- 오류가 다음 상승 에지까지 유지되면 FSM이 환불 상태로 이동하고 error_q가 한 클록 동안 오류를 유지합니다.
- 클록 사이에만 나타났다 사라지는 잘못된 ID는 순간적인 error로 표시되지만 저장되거나 환불을 일으키지 않습니다.
- error는 조합 표시와 저장된 이벤트의 OR입니다. 따라서 순수한 조합 출력만으로 이루어진 것은 아니며, 전체 error 펄스 길이가 정확히 한 클록이라고 보장하지 않습니다.
- 상품 ID 버스가 비동기적으로 바뀌거나 여러 비트가 서로 다른 시점에 바뀌면 순간 오류가 발생할 수 있습니다. 소비 측의 동기화 또는 별도 selection_valid가 필요할 수 있습니다.
- 반환, 배출 및 나머지 오류 처리는 동기식으로 유지됩니다. 모든 출력의 비동기화를 요청한 것으로 해석하지 않았습니다.

## 검증

- 즉시 응답 전용 테스트: 12 assertions 통과. 다음 상승 에지 전 오류 발생, 유효 ID 복구, 샘플링된 오류 유지, 리셋 검증.
- 기존 spec_fixed 회귀 테스트: 32개 시나리오·156 assertions 통과.
- 원본 CVDP 공식 평가 실행 완료: 실패. 내부 pytest 10회 모두 첫 구매의 거스름돈 출력 시점 검사에서 중단했습니다. 즉시 오류 출력 검사를 포함한 이후 시나리오까지 도달하지 않았으므로, 공식 테스트의 오류 처리 문제가 해결됐는지는 이 실행만으로 판단할 수 없습니다.

로그: /Users/bagjunbeom/Downloads/CVDP/logs/vending-comb-error.log

## 공식 평가 결과 (2026-09-24)

실행 경로: `work_vending_comb_20260924_204429`

실패 assertion: `Change should not be returned change in this clock cycle`

조합논리 변경은 상품 ID의 error 경로만 수정했으며, 배출 바로 다음 클록에 return_change를 내는 동작은 유지했습니다. 따라서 공식 테스트가 한 클록 더 늦게 반환을 기대하는 차이가 남아 있습니다. 이번 실행의 10회 실패는 이 첫 실패 지점을 의미하며 서로 다른 10개 결함을 의미하지 않습니다.

[공식 로그](../../evaluation_evidence/work_vending_comb_20260924_204429/cvdp_copilot_vending_machine/reports/1.txt)
