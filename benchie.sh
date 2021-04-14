#!/bin/sh

set -eu

# Usage
if [ "$1" = '--help' ] || [ "$1" = '-h' ] || [ "$1" = 'help' ]; then
    echo 'Usage:'
    echo './benchie.sh [command]] [opts]'
    echo ''
    echo './benchie.sh start [benchmark] [[label]]'
    echo '# Starts the path/to/benchmark benchmark. Benchmark data created in path/to/benchmark/data'
    echo './benchie.sh start client-network-latency'
    echo './benchie.sh start client-network-latency homewifi'
    echo './benchie.sh start client-network-latency hotspot'
    echo './benchie.sh start client-network-latency wsgx'
    echo ''
    echo './benchie.sh status [benchmark]'
    echo '# Gets all the benchmark PIDs of client-network-latency benchmark'
    echo './benchie.sh status client-network-latency'
    echo ''
    echo './benchie.sh stop [benchmark]'
    echo '# Kills all the benchmark PIDs of client-network-latency benchmark'
    echo './benchie.sh stop client-network-latency'
    echo ''
    echo './benchie.sh clean [benchmark]'
    echo '# Cleans all the benchmark data folder client-network-latency/data'
    echo './benchie.sh clean client-network-latency'
    exit 0
fi

# Arguments
if [ "$#" -eq 0 ]; then
    echo "Please provide a command as first argument. E.g. 'start', 'stop'"
    exit 1
fi
COMMAND="$1"
shift

if [ "$#" -eq 0 ]; then
    echo "Please provide a benchmark as second argument. E.g. 'path/to/benchmark'"
    exit 1
fi
BENCHMARK="$1"
shift

BENCHMARK_OPTIONAL_LABEL=
if [ "$#" -gt 0 ]; then
    BENCHMARK_OPTIONAL_LABEL="$1"
    shift
fi

# Helpers for OSX: https://stackoverflow.com/questions/3572030/bash-script-absolute-path-with-os-x
if ! which realpath > /dev/null 2>&1; then
    realpath() {
        local OURPWD=$PWD
        cd "$(dirname "$1")"
        local LINK=$(readlink "$(basename "$1")")
        while [ "$LINK" ]; do
            cd "$(dirname "$LINK")"
            local LINK=$(readlink "$(basename "$1")")
        done
        local REALPATH="$PWD/$(basename "$1")"
        cd "$OURPWD"
        echo "$REALPATH"
    }
fi

# Functions
dnsify() {
    echo "$1" | sed 's/[^a-zA-Z0-9_-]/-/g'
}
trim() {
    sed 's/^\s*\|\s*$//' | awk NF
}

## Declaration
BASE_DIR=$( pwd )
BENCHMARK_BASE_DIR=$( realpath "$BENCHMARK" )
if [ ! -d "$BENCHMARK_BASE_DIR" ]; then
    # Try relative path
    BENCHMARK_BASE_DIR=$( realpath "$BASE_DIR/$BENCHMARK" )
    if [ ! -d "$BENCHMARK_BASE_DIR" ]; then
        echo "Could not find BENCHMARK_BASE_DIR: $BENCHMARK_BASE_DIR"
        exit 1
    fi
fi

BENCHMARK_DATA_DIR="$BENCHMARK_BASE_DIR/data"
BENCHMARK_COMMANDS_FILE="$BENCHMARK_BASE_DIR/commands"
COMMAND=${COMMAND:-}
BENCHMARK=${BENCHMARK:-}
BENCHMARK_OPTIONAL_LABEL=${BENCHMARK_OPTIONAL_LABEL:-}
if [ ! -f "$BENCHMARK_COMMANDS_FILE" ]; then
    echo "Could not find BENCHMARK_COMMANDS_FILE: $BENCHMARK_COMMANDS_FILE"
    exit 1
fi
BENCHMARK_COMMANDS=$( cat "$BENCHMARK_COMMANDS_FILE" )

# Normalization of configuration
COMMAND=$( echo "$COMMAND" | trim )
BENCHMARK=$( echo "$BENCHMARK" | trim )
BENCHMARK_OPTIONAL_LABEL=$( echo "$BENCHMARK_OPTIONAL_LABEL" | trim )
BENCHMARK_COMMANDS=$( echo "$BENCHMARK_COMMANDS" | trim )

# Validation of configuration
if ! echo "$COMMAND" | grep -E '^(start|status|stop|clean)$' > /dev/null 2>&1; then
    echo "COMMAND must be one of: start|status|stop|clean"
    exit 1
fi
if [ -z "$BENCHMARK_COMMANDS" ]; then
    echo "No BENCHMARK_COMMANDS defined."
    exit 1
fi

# OS-specific configuration
OS_ALPINE=
if cat /etc/os-release | grep -iE 'ID=alpine' > /dev/null 2>&1; then
    OS_ALPINE='true'
fi

## Create directories
mkdir -p "$BENCHMARK_DATA_DIR"

if [ "$COMMAND" = 'start' ]; then
    # Run benchmarks
    # Returns benchmark data files
    echo "$BENCHMARK_COMMANDS" | while read -r c; do
        BENCHMARK_DATA_FILE_BASENAME="$( date -u '+%Y-%m-%d-%H-%M-%S-%Z' )-$( hostname )-$( dnsify "$c" )"
        if [ -n "$BENCHMARK_OPTIONAL_LABEL" ]; then
            BENCHMARK_DATA_FILE_BASENAME="$BENCHMARK_DATA_FILE_BASENAME-$( dnsify "$BENCHMARK_OPTIONAL_LABEL" )"
        fi
        BENCHMARK_DATA_FILE_NAME="$BENCHMARK_DATA_FILE_BASENAME.txt"
        BENCHMARK_DATA_FILE="$BENCHMARK_DATA_DIR/$BENCHMARK_DATA_FILE_NAME"

        sh -c "$c >> \"$BENCHMARK_DATA_FILE\"" &
        echo "$BENCHMARK_DATA_FILE"
    done
fi
if [ "$COMMAND" = 'status' ]; then
    # Get running benchmarks
    # Returns pid
    echo "$BENCHMARK_COMMANDS" | while read -r c; do
        if [ "$OS_ALPINE" = 'true' ]; then
            for i in $( ps aux | grep "$c" | grep -v grep | awk '{print $1}'); do echo "$i"; done
        else
            for i in $( ps aux | grep "$c" | grep -v grep | awk '{print $2}'); do echo "$i"; done
        fi
    done
fi
if [ "$COMMAND" = 'stop' ]; then
    # Stops benchmarks
    # Returns killed pid
    echo "$BENCHMARK_COMMANDS" | while read -r c; do
        if [ "$OS_ALPINE" = 'true' ]; then
            for i in $( ps aux | grep "$c" | grep -v grep | awk '{print $1}'); do echo "$i"; kill -9 "$i"; done
        else
            for i in $( ps aux | grep "$c" | grep -v grep | awk '{print $2}'); do echo "$i"; kill -9 "$i"; done
        fi
    done
fi
if [ "$COMMAND" = 'clean' ]; then
    # Clean benchmark
    # Returns removed benchmark data files
    find "$BENCHMARK_DATA_DIR" -name '*.txt' | while read -r l; do
        rm -f "$l"
        echo "$l"
    done
fi
