"""Produce counts from official per-test results, never CLI exit codes."""
import json,hashlib
from pathlib import Path
BASE=Path(__file__).resolve().parent;ROOT=BASE.parents[1]
final_raw=ROOT/'work_next50_final/raw_result.json'
if not final_raw.exists():raise SystemExit('Final evaluation still running; no report generated.')
final=json.loads(final_raw.read_text());attempts=json.loads((BASE/'attempts.json').read_text());sources=json.loads((BASE/'final_sources.json').read_text())
mfile=ROOT/'selections/next_50/manifest.json';manifest=json.loads(mfile.read_text());diag=json.loads((BASE/'diagnostics/results.json').read_text());diags={r['id']:r for r in diag}
def passed(v):return bool(v['tests']) and all(t['result']==0 for t in v['tests'])
assert len(final)==50 and len(sources)==50
assert hashlib.sha256((ROOT/manifest['source']).read_bytes()).hexdigest()==manifest['source_sha256']
records=[]
for problem in manifest['problems']:
 key=problem['id'];first=attempts[key][0];v=final[key];ok=passed(v);p=BASE/'final'/(key+'.sv')
 rec={'order':problem['order'],'id':key,'title_ko':problem['title_ko'],'batch':problem['batch'],'first_pass':first['passed'],'final_pass':ok,'status':'official_pass' if ok else 'official_fail','source_revision':sources[key]['revision'],'rtl':str(p),'rtl_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'official_tests':v['tests'],'diagnostic':diags.get(key)}
 records.append(rec);problem['status']=rec['status'];problem['evaluation']={'first_pass':first['passed'],'final_pass':ok,'rtl':str(p.relative_to(ROOT)),'result_file':'work_next50_final/raw_result.json'}
count=sum(r['final_pass'] for r in records);first_count=sum(r['first_pass'] for r in records)
summary={'attempted':50,'first_official_pass':first_count,'final_official_pass':count,'final_official_fail':50-count,'independent_diagnostic_pass':sum(d['passed'] for d in diag),'subjective_score':None,'official_result':str(final_raw),'problems':records}
(BASE/'results.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n')
manifest['status']='evaluated_with_remaining_failures' if count<50 else 'official_all_pass';manifest['evaluation_summary']={k:v for k,v in summary.items() if k!='problems'}
mfile.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
lines=['# 다음 50문제 RTL 풀이 결과','',f'**50개 구현·공식 평가 완료. 첫 시도 {first_count}/50 → 수정 후 통합 재평가 {count}/50 통과.**',f'공식 미통과 {50-count}개는 별도 진단 7개를 통과했지만 공식 통과 수에 포함하지 않는다. 모든 테스트 결과가 0인 문제만 PASS로 센다.','',f'- [최종 공식 결과]({final_raw})',f'- [50개 최종 RTL]({BASE}/final)',f'- [미통과 원인·진단 범위]({BASE}/FAILURES_KO.md)',f'- [구현 및 평가 해석 주의점]({BASE}/IMPLEMENTATION_NOTES_KO.md)',f'- [기계 판독 결과·RTL SHA-256]({BASE}/results.json)',f'- [수정 이력]({BASE}/attempts.json)','', '## 묶음별 결과','','| 묶음 | 첫 시도 | 최종 공식 |','|---|---:|---:|']
for b in range(1,6):
 rs=[r for r in records if r['batch']==b];lines.append(f'| {b} | {sum(r["first_pass"] for r in rs)}/10 | {sum(r["final_pass"] for r in rs)}/10 |')
lines+=['','## 전체 50개','','| 번호 | 문제 | 첫 시도 | 최종 공식 | RTL |','|---:|---|---|---|---|']
for r in records:
 lines.append(f'| {r["order"]} | {r["title_ko"]} | {"PASS" if r["first_pass"] else "FAIL"} | {"PASS" if r["final_pass"] else "FAIL · 별도 진단만 PASS"} | [{r["id"].removeprefix("cvdp_copilot_")}]({r["rtl"]}) |')
lines+=['','## 재실행','','```sh','./scripts/cvdp benchmark -f solutions/next_50/final/dataset.jsonl -l -m local_import \\','  --prompts-responses-file solutions/next_50/final/responses.jsonl -p work_next50_recheck','```','','작업 디렉터리는 `/Users/bagjunbeom/Downloads/CVDP`이다. Docker/Colima 실행 환경이 필요하다. 일부 테스트는 무작위 자극·파라미터를 사용하므로 재실행 시 샘플이 달라진다.','','첫 답안은 원문/제공 코드로 작성했고, 수정본은 실패 후 테스트를 확인했다. 정답 RTL을 복사한 결과가 아니다. 원본 데이터셋 SHA-256은 선정 당시와 동일하다. 원본 harness는 변경하지 않았다. API 키가 없는 주관 평가 점수는 주장하지 않는다.','']
(BASE/'RESULTS_KO.md').write_text('\n'.join(lines))
p=ROOT/'selections/next_50/README_KO.md';s=p.read_text();old='**50문제 선정 완료 — Easy 20개 / Medium 30개. 아직 답안 작성·시뮬레이션은 하지 않았습니다.**';s=s.replace(old,f'**50문제 구현·평가 완료 — 첫 시도 {first_count}/50, 수정 후 공식 {count}/50 통과.**\n\n[전체 결과와 남은 문제]({BASE}/RESULTS_KO.md)');p.write_text(s)
print(json.dumps({k:v for k,v in summary.items() if k!='problems'},ensure_ascii=False))
