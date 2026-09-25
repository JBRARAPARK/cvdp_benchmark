"""Assemble a reviewable answer set; keep every evaluated attempt immutable."""
import json,shutil
from pathlib import Path
base=Path(__file__).resolve().parent;root=base.parents[1]
runs=[(f'work_next50_batch{i:02d}_first'+('_valid' if i==3 else ''),'first') for i in range(1,6)]
runs += [(f'work_next50_r{i}',f'revised_r{i}') for i in range(1,7)]
selected={};attempts={}
for name,rev in runs:
 for key,value in json.loads((root/name/'raw_result.json').read_text()).items():
  passed=bool(value['tests']) and all(t['result']==0 for t in value['tests'])
  entry={'run':name,'revision':rev,'passed':passed,'tests':value['tests'],'rtl':str(base/rev/(key+'.sv'))}
  attempts.setdefault(key,[]).append(entry)
  if key not in selected or passed:selected[key]=entry
# Preferred nonpassing sources with interface fixes and independent diagnostics.
for key,rev in {'serial_in_parallel_out_0014':'revised_r1','ping_pong_buffer_0001':'revised_r5','microcode_sequencer_0001':'revised_r5'}.items():
 key='cvdp_copilot_'+key;selected[key]=next(a for a in attempts[key] if a['revision']==rev)
final=base/'final';final.mkdir(exist_ok=True)
for key,entry in selected.items():shutil.copyfile(entry['rtl'],final/(key+'.sv'))
(base/'attempts.json').write_text(json.dumps(attempts,indent=2));(base/'final_sources.json').write_text(json.dumps(selected,indent=2))
print('Selected',len(selected),'official pass',sum(v['passed'] for v in selected.values()))
