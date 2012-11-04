#!/bin/bash
GEMSET="io_shuten"
BENCHMARKS=`ls benchmarks`
BENCH_OUT="benchmark/out.rash"
BENCH_REP="benchmark/report"
BENCH_RUN=1

echo "Running benchmarks ..."
for bench in $BENCHMARKS; do
  echo "  - ${bench}"
  viiite run --runs=$BENCH_RUN $bench >> $BENCH_OUT 2>/dev/null
done

viiite report $BENCH_OUT -h --regroup=bench,type > ${BENCH_REP}.bench-type.txt
viiite report $BENCH_OUT -h --regroup=type,bench > ${BENCH_REP}.type-bench.txt

[[ -e "$BENCH_OUT" ]] && rm $BENCH_OUT

echo
echo "Reports created."
