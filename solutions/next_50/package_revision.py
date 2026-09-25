"""Package authored revisions, preserving original dataset and harness bytes."""
import json,sys
from pathlib import Path
base=Path(__file__).resolve().parent;root=base.parents[1];rev=base/sys.argv[1]
rows=[json.loads(x) for x in (root/'selections/next_50/selected.jsonl').read_text().splitlines()]
selected=[];responses=[]
for r in rows:
 p=rev/(r['id']+'.sv')
 if not p.exists():continue
 s=p.read_text();names=list(r['output']['context']) # filenames only; never read reference contents
 if len(names)>1:
  if 'huffman' in r['id']:
   split=s.index('module single_port_ram');parts={names[0]:s[:split],names[1]:s[split:]}
  elif 'ping_pong' in r['id']:parts={names[0]:s,names[1]:r['input']['context'][names[1]]}
  else:raise ValueError(names)
  s=json.dumps({'code':[{k:v} for k,v in parts.items()]})
 selected.append(r);responses.append({'id':r['id'],'completion':s})
(rev/'dataset.jsonl').write_text(''.join(json.dumps(r)+'\n' for r in selected))
(rev/'responses.jsonl').write_text(''.join(json.dumps(r)+'\n' for r in responses))
print(len(selected))
