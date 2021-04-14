# `benchie`

A simple benchmarking tool.

## Usage

1. Vendor the `benchie.sh` into `tools/` of a new repo.

```sh
cd benchie-data
mkdir -p tools
```

1. Create a new benchmark

```sh
cd benchie-data
mkdir -p my-benchmark
echo 'ping -W 1 1.1.1.1' > my-benchmark/commands
echo 'ping -W 1 192.168.0.1' >> my-benchmark/commands
```

1. Start benchmark

```sh
cd benchie-data
`./tools/benchie my-benchmark
```
