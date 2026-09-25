# 구현·평가 해석 시 주의점

- 첫 답안은 `first/`, 실패 후 수정은 `revised_r1/`~`revised_r6/`, 최종 제출본은 `final/`에 보관했다. 수정본은 실패 로그와 테스트를 확인한 뒤 작성했으므로 첫 시도 성적과 분리한다. 정답 RTL 본문은 읽지 않았으며, 다중 파일 패키징에는 출력 파일명만 사용했다.
- 최초 50개 평가는 컴파일·실행 실패를 포함해 모두 기록한다. AXI ALU의 응답 대기 교착은 컨테이너를 중단했고 `137`로 기록되었다. 수정 r1의 성능 카운터는 32비트 전체 카운팅(수십억 사이클) 때문에 중단했다. 기본 폭이 원문에서 지정되지 않아 최종 기본값을 8로 정했으며 CNT_W는 계속 매개변수화되어 있다.
- Huffman/핑퐁의 첫 실패에는 다중 파일 답안을 단일 문자열로 제출한 포장 오류가 포함되어 있다. 이 실패도 첫 시도에서 제외하지 않았다.
- 가산 트리는 배열 크기와 혼합 procedural/continuous 드라이버를 수정했다. Icarus 버전별 선언 전 사용 처리 차이는 캐시 및 AXI ALU에서 선언 순서를 정리해 해결했다.
- RDN 반올림의 all-ones 포화와 RS의 일반 정수 곱셈 기반 parity는 공식 테스트의 문제별 규칙을 따른다. 범용 IEEE 부동소수점 반올림/완전한 GF 기반 Reed–Solomon 구현이라고 주장하지 않는다.
- AXI TAP은 원문 prose의 active-low와 제공 RTL/테스트의 active-high가 충돌한다. 최종본은 `RESET_ACTIVE_LOW=0`을 기본값으로 제공 RTL을 따르며 1로 설정하면 prose의 극성을 선택한다. 이 파라미터 1 설정은 공식 테스트 대상이 아니다.
- static branch predictor는 문제에 적힌 PC-relative JALR 식을 따른다. 표준 RISC-V JALR과 차이가 있다. 테스트가 사용하는 `register_addr_i`도 추가했다.
- IR 수신기의 최종 대기시간은 테스트가 사용하는 약 40ms 프레임 간격을 수용하며, 최초 구현의 45ms 잠금을 완화했다. 3클록 측정 기준도 공식 샘플링 시점에 맞춰 조정했다.
- TLB는 제공된 조합 page-table lookup을 miss에 bypass하고 캐시에 매클록 채운다. 최종 register file의 읽기는 조합 방식으로 바꿨다. 이 변경들은 공식 테스트가 기대하는 지연을 수용하며, 최초 답안의 파이프라인과 다르다.
- Huffman 공식 테스트는 대부분 무작위 입력 후 reset/error_flag만 확인한다. 최종 답안은 zero-length/zero-code를 비활성 테이블 항목으로 허용하고 해당 심벌 인코딩 시 오류 처리한다. 명시된 single-port RAM/FSM 구조를 완전히 검증한 결과는 아니며, 합성 후 구조·타이밍·면적은 검증하지 않았다.
- 원본 공식 테스트 통과는 해당 테스트 범위의 기능 PASS이다. formal proof, CDC sign-off, 물리적 clock switching 안전성, 모든 파라미터 조합, PPA를 보장하지 않는다. 특히 AXI ALU의 버스 CDC는 개별 동기화 방식으로 기능 검증됐으며 물리 CDC 검증은 별도 작업이다.
- Subjective scoring API 키 경고는 남아 있다. 이번 작업은 직접 작성한 RTL을 `local_import`로 넣어 객관적 시뮬레이션 결과만 집계한다. 주관 평가 점수는 없다.
