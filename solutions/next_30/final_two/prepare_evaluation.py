import json,copy
from pathlib import Path
base=Path('solutions/next_30/final_two');names={'cvdp_copilot_simple_spi_0001':'spi_fsm.sv','cvdp_copilot_interrupt_controller_0017':'interrupt_controller.sv'}
rows=[json.loads(s) for s in Path('selections/next_30/selected.jsonl').read_text().splitlines()];rows=[r for r in rows if r['id'] in names]
def save(name,data): (base/name).write_text(''.join(json.dumps(r)+'\n' for r in data))
save('official_dataset.jsonl',rows);save('responses.jsonl',[{'id':r['id'],'completion':(base/names[r['id']]).read_text()} for r in rows])
diag=copy.deepcopy(rows)
for r in diag:
 files=r['harness']['files']
 if 'simple_spi' in r['id']:
  k='src/test_spi_fsm.py';s=files[k]
  s=s.replace('await RisingEdge(dut.o_spi_clk)','await RisingEdge(dut.o_spi_clk)\n    await Timer(1, unit="ns")')
  s=s.replace('    # Check end of transmission','    # Diagnostic correction: also check the sixteenth (LSB) bit.\n    await RisingEdge(dut.o_spi_clk)\n    await Timer(1, unit="ns")\n    assert_equal(dut.o_spi_data.value, 0xABCD & 1, "Final bit")\n    assert_equal(dut.o_bits_left.value, 0, "Final count")\n\n    # Check end of transmission')
  files[k]=s
 else:
  k='src/test_int_controller.py';s=files[k]
  s=s.replace('    # Initialize signals','    # Diagnostic correction: define the mask input.\n    dut.interrupt_mask.value = 0\n\n    # Initialize signals')
  files[k]=s
save('diagnostic_dataset.jsonl',diag)
