# benchie

[![github-actions](https://github.com/theohbrothers/benchie/workflows/ci-master-pr/badge.svg)](https://github.com/theohbrothers/benchie/actions)
[![github-tag](https://img.shields.io/github/tag/theohbrothers/benchie)](https://github.com/theohbrothers/benchie/releases/)
<!-- [![docker-image-size](https://img.shields.io/docker/image-size/theohbrothers/benchie/latest)](https://hub.docker.com/r/theohbrothers/benchie) -->

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

6. Commit benchmark data to your benchmark repo

```sh
git commit -am 'Add client-network-latency benchmark results'
```

7. Clean benchmark data

```sh
./tools/benchie/benchie.sh clean client-network-latency
# Benchmark data removed in ./client-network-latency/data
```

## Notes

Use `benchie.sh --help` for command line usage.
