#!/bin/bash

set -e

#  git clone "https://github.com/brendangregg/FlameGraph.git"
FLAME_GRAPH_DIR="${HOME}/open_source/FlameGraph"

# Usage:
# perf_app app_name

[ ! -d "${FLAME_GRAPH_DIR}" ] && git clone https://github.com/brendangregg/FlameGraph.git "${HOME}/open_source/FlameGraph"

BASE_NAME="`pwd`/${1}_`date +%s`"
PERF_RAW="${BASE_NAME}.perf"
FLAMEGRAPH_IMG="${BASE_NAME}.svg"

echo $PERF_RAW
echo $FLAMEGRAPH_IMG

sudo perf record -v -F 997 -BNT -e cpu-clock --call-graph dwarf,65528 --clockid=monotonic_raw -o $PERF_RAW -p $1 -- sleep 20

sudo perf script -i $PERF_RAW | ${FLAME_GRAPH_DIR}/stackcollapse-perf.pl | ${FLAME_GRAPH_DIR}/flamegraph.pl > FLAMEGRAPH_IMG
