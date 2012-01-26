#!/bin/bash
echo "Loading RVM ..."
[[ -s $rvm_path/scripts/rvm ]] && source $rvm_path/scripts/rvm >/dev/null 2>&1

RUBIES="ruby-1.8.7-p352 ruby-1.8.7-p357 ruby-1.9.2-p290 ruby-1.9.2-p290-gc ruby-1.9.3-p0"
GEMSET="io_shuten"
BENCHMARKS=`ls benchmarks`
BENCH_OUT="benchmark/out.rash"
BENCH_REP="benchmark/report"
BENCH_RUN=10

[[ -e "$BENCH_OUT" ]] && rm $BENCH_OUT
touch $BENCH_OUT

for ruby in $RUBIES; do

  echo
  echo "Switching to: $ruby@$GEMSET"
  rvm use --create $ruby@$GEMSET >/dev/null 2>&1

  bundler_installed=`gem list bundler | awk '$1~/bundler/ { print $1 }'`
  if [[ -z "$bundler_installed" ]]; then
    echo "Installing bundler ..."
    gem install bundler --pre >/dev/null 2>&1
  fi

  echo "Installing gems ..."
  bundle install >/dev/null 2>&1

  echo "Running benchmarks ..."
  for bench in $BENCHMARKS; do
    viiite run --runs=$BENCH_RUN $bench >> $BENCH_OUT 2>/dev/null
  done

done

viiite report $BENCH_OUT -h --regroup=bench,ruby,type > ${BENCH_REP}.bench-ruby-type.txt
viiite report $BENCH_OUT -h --regroup=bench,type,ruby > ${BENCH_REP}.bench-type-ruby.txt
viiite report $BENCH_OUT -h --regroup=ruby,bench,type > ${BENCH_REP}.ruby-bench-type.txt
viiite report $BENCH_OUT -h --regroup=ruby,type,bench > ${BENCH_REP}.ruby-type-bench.txt
viiite report $BENCH_OUT -h --regroup=type,bench,ruby > ${BENCH_REP}.type-bench-ruby.txt
viiite report $BENCH_OUT -h --regroup=type,ruby,bench > ${BENCH_REP}.type-ruby-bench.txt

[[ -e "$BENCH_OUT" ]] && rm $BENCH_OUT

echo
echo "Reports created."

