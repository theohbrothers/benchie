# `benchie`

A simple benchmarking tool.

## Usage

1. Vendor `benchie.sh` into your benchmark repo. E.g. `my-benchmarks`

```sh
cd my-benchmarks
git submodule add https://github.com/theohbrothers/benchie tools/benchie
```

2. Create a new benchmark. E.g. `client-network-latency`

```sh
mkdir -p client-network-latency
echo 'ping -W 1 1.1.1.1' > client-network-latency/commands
echo 'ping -W 1 192.168.0.1' >> client-network-latency/commands
```

3. Start benchmark

```sh
./tools/benchie/benchie.sh start client-network-latency <benchmark_label>
# Benchmark data now in ./client-network-latency/data
```

4. Get status of benchmark

```sh
./tools/benchie/benchie.sh status client-network-latency
```

5. Stop benchmark

```sh
./tools/benchie/benchie.sh status client-network-latency
```

6. Clean benchmark data

```sh
./tools/benchie/benchie.sh clean client-network-latency
# Benchmark data removed in ./client-network-latency/data
```

## Notes

Use `benchie.sh --help` for command line usage.
