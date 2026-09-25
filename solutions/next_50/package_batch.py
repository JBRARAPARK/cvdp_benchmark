import json,sys
from pathlib import Path
b=int(sys.argv[1]);base=Path(__file__).resolve().parent;root=base.parents[1]
rows=[json.loads(s) for s in (root/f'selections/next_50/batch_{b:02d}.jsonl').read_text().splitlines()]
out=[]
for r in rows:
 p=base/'first'/(r['id']+'.sv');out.append({'id':r['id'],'completion':p.read_text()})
(base/'first'/f'batch_{b:02d}_responses.jsonl').write_text(''.join(json.dumps(r)+'\n' for r in out))
