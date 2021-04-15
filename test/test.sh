#!/bin/sh

set -u

# Test env
BASE_DIR=$( pwd )
TEST_DIR_BASENAME='test'
TEST_DIR="$BASE_DIR/$TEST_DIR_BASENAME"
BENCHMARK="my-benchmark"
BENCHMARK_DIR_REL="$TEST_DIR_BASENAME/$BENCHMARK"
BENCHMARK_DIR="$TEST_DIR/$BENCHMARK"
BENCHMARK_DATA_DIR="$TEST_DIR/$BENCHMARK/data"
TEST_STDOUT_FILE="$TEST_DIR/.stdout"

pass=0
fail=0
total=0
passed() {
    echo 'pass' && pass=$( expr $pass + 1 ) && total=$( expr $total + 1 )
}
failed() {
    echo 'fail' && fail=$( expr $fail + 1 ) && total=$( expr $total + 1 )
}
cleanup() {
    rm -f "$TEST_STDOUT_FILE"
}

#
# Relative benchmark directory
#

echo
echo "[Test start]"
for bd in $BENCHMARK_DIR $BENCHMARK_DIR_REL; do
    ./benchie.sh start "$bd" > "$TEST_STDOUT_FILE"
    STDOUT=$( cat "$TEST_STDOUT_FILE" )
    echo "Expect an absolute path to benchmark data file"
    echo "$STDOUT" | grep -E "[a-zA-Z0-9_-]+.txt$" > /dev/null && passed || failed
    echo "Expect benchmark data file exists"
    ls $STDOUT > /dev/null && passed || failed
    echo "Expect content of benchmark data file"
    cat $STDOUT && passed || failed
    cleanup

    echo
    echo "[Test status]"
    ./benchie.sh status "$bd" > "$TEST_STDOUT_FILE"
    STDOUT=$( cat "$TEST_STDOUT_FILE" )
    echo "Expect a pid"
    echo "$STDOUT" | grep -E "[0-9]+" > "$TEST_STDOUT_FILE" && passed || failed
    echo "Expect pid to be running"
    kill -0 $STDOUT > /dev/null 2>&1 && passed || failed
    cleanup

    echo
    echo "[Test stop]"
    ./benchie.sh stop "$bd" > "$TEST_STDOUT_FILE"
    STDOUT=$( cat "$TEST_STDOUT_FILE" )
    echo "Expect a pid"
    echo "$STDOUT" | grep -E "[0-9]+" > "$TEST_STDOUT_FILE" && passed || failed
    echo "Expect pid no longer exist"
    kill -0 $STDOUT > /dev/null 2>&1 && failed || passed
    cleanup

    echo
    echo "[Test clean]"
    ./benchie.sh clean "$bd" > "$TEST_STDOUT_FILE"
    STDOUT=$( cat "$TEST_STDOUT_FILE" )
    echo "Expect an absolute path to benchmark data file"
    echo "$STDOUT" | grep -E "[a-zA-Z0-9_-]+.txt$" > /dev/null && passed || failed
    echo "Expect benchmark data directory to be clean"
    ls test/my-benchmark/data/ | wc -l | awk '{print $1}' | grep -E '^0$' > /dev/null && passed || failed
    cleanup
done

echo
echo "[Summary]"
echo "Total: $total"
echo "Pass: $pass"
echo "Fail: $fail"
if [ $fail -eq 0 ]; then
    echo "Overall status: pass"
    exit 0
else
    echo "Overall status: fail"
    exit 1
fi
