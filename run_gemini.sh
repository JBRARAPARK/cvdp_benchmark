#!/bin/bash
export COMPOSE_ANSI=never
export BUILDKIT_PROGRESS=plain
export BUILDKIT_DISPLAY=plain

rm -rf work_gemini
./run_benchmark.py \
  -f example_dataset/cvdp_v1.1.0_example_nonagentic_code_generation_no_commercial.jsonl \
  -l \
  -m gemini-3.5-flash \
  -c gemini_factory.py \
  -p work_gemini

cat work_gemini/report.txt
