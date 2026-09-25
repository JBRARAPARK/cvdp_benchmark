#!/bin/sh
set -eu
iverilog -g2012 -s tb -o /tmp/cvdp_spi spi_fsm.sv spi_tb.sv
vvp /tmp/cvdp_spi
for threshold in 1 5 20; do
  iverilog -g2012 -s tb -Ptb.THRESHOLD=$threshold -o /tmp/cvdp_irq interrupt_controller.sv interrupt_tb.sv
  vvp /tmp/cvdp_irq
done
