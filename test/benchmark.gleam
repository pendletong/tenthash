import bigi
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import glychee/benchmark
import glychee/configuration
import minigen
import tenthash

pub fn main() {
  // Configuration is optional
  configuration.initialize()
  configuration.set_pair(configuration.Warmup, 2)
  configuration.set_pair(configuration.Parallel, 2)

  hash_benchmark()
  // bigi_benchmark()
}

fn bigi_benchmark() {
  benchmark.run(
    [
      benchmark.Function(label: "hash()", callable: fn(test_data) {
        fn() { list.each(test_data, bigi.from_string) }
      }),
    ],
    [
      benchmark.Data(label: "From String", data: [
        "6732230515997387111", "16297768295691943732", "14578299661238189102",
        "9893891307554648435",
      ]),
    ],
  )
  benchmark.run(
    [
      benchmark.Function(label: "hash()", callable: fn(test_data) {
        fn() {
          list.each(test_data, bigi.from_bytes(_, bigi.BigEndian, bigi.Unsigned))
        }
      }),
    ],
    [
      benchmark.Data(
        label: "From String",
        data: [
          "6732230515997387111", "16297768295691943732", "14578299661238189102",
          "9893891307554648435",
        ]
          |> list.map(fn(s) {
            bigi.from_string(s)
            |> result.unwrap(bigi.zero())
            |> bigi.to_bytes(bigi.BigEndian, bigi.Unsigned, 8)
            |> result.unwrap(<<>>)
          }),
      ),
    ]
      |> io.debug,
  )
}

fn hash_benchmark() {
  // Run the benchmarks
  benchmark.run(
    [
      benchmark.Function(label: "hash()", callable: fn(test_data) {
        fn() { tenthash.hash(test_data) }
      }),
    ],
    [
      benchmark.Data(
        label: "10 chars",
        data: minigen.string(10)
          |> minigen.run,
      ),
      benchmark.Data(
        label: "100 chars",
        data: minigen.string(100)
          |> minigen.run,
      ),
      benchmark.Data(
        label: "1000 chars",
        data: minigen.string(1000)
          |> minigen.run,
      ),
      benchmark.Data(
        label: "10000 chars",
        data: minigen.string(10_000)
          |> minigen.run,
      ),
      benchmark.Data(
        label: "100000 chars",
        data: minigen.string(100_000)
          |> minigen.run,
      ),
      benchmark.Data(
        label: "1000000 chars",
        data: minigen.string(1_000_000)
          |> minigen.run,
      ),
    ],
  )
}
