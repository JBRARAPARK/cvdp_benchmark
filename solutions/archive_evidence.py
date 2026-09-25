"""Archive result JSON and referenced logs, excluding disposable work directories."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'solutions/evaluation_evidence'
RUN_MARKERS=('next30','next50','rep10','vending','llm_example')
entries=[]
for result in sorted(ROOT.glob('work*/raw_result.json')):
    if not any(s in result.parent.name for s in RUN_MARKERS):continue
    selected={result}
    report=result.parent/'report.txt'
    if report.exists():selected.add(report)
    for value in json.loads(result.read_text()).values():
        for test in value.get('tests',[]):
            log=Path(test.get('log',''))
            if log.is_file() and log.is_relative_to(result.parent):selected.add(log)
    for path in sorted(selected):
        relative=path.relative_to(ROOT);target=OUT/relative
        target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(path,target)
        entries.append({'original':str(relative),'archived':str(target.relative_to(ROOT)),'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'bytes':target.stat().st_size})
OUT.mkdir(parents=True,exist_ok=True)
(OUT/'index.json').write_text(json.dumps(entries,indent=2)+'\n')
print(f'Archived {len(entries)} files, {sum(e["bytes"] for e in entries)/1048576:.1f} MiB')
