"""Run original-requirement diagnostics against retry RTL, without compatibility defaults."""
from pathlib import Path
import json,subprocess
B=Path(__file__).resolve().parent;D=B/'diagnostics';D.mkdir(exist_ok=True)
# Reuse the authored independent testbench stimuli, not reference answers.
old=B.parent/'diagnostics';cases=json.loads((old/'results.json').read_text());results=[]
for c in cases:
 tb=old/(c['check']+'.sv');rtl=B/'rtl'/(c['id']+'.sv');extra=[str(old/'dual_port_memory.sv')] if 'ping_pong' in c['id'] else []
 exe=D/(c['check']+'.vvp');a=subprocess.run(['iverilog','-g2012','-s','tb','-o',str(exe),str(rtl),str(tb)]+extra,capture_output=True,text=True,timeout=20)
 b=subprocess.run(['vvp',str(exe)],capture_output=True,text=True,timeout=20) if a.returncode==0 else a
 out=a.stdout+a.stderr+b.stdout+b.stderr;(D/(c['check']+'.log')).write_text(out)
 results.append({'id':c['id'],'check':c['check'],'passed':b.returncode==0,'rtl':str(rtl),'log':str(D/(c['check']+'.log'))});print(c['check'],b.returncode)
 if exe.exists():exe.unlink()
(D/'results.json').write_text(json.dumps(results,indent=2))
