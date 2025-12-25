import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Indexes {
  Indexes(i: Int, j: Int)
}

pub fn solve() {
  let split = input |> string.split("\n\n")
  let assert Ok(ranges) = split |> list.first()
  let assert Ok(vals) = split |> list.last()

  let ranges =
    list.fold(from: [], over: ranges |> string.split("\n"), with: fn(acc, r) {
      let range_split = r |> string.split("-")
      let assert Ok(Ok(start)) =
        range_split |> list.first() |> result.map(int.parse)
      let assert Ok(Ok(end)) =
        range_split |> list.last() |> result.map(int.parse)
      [#(start, end), ..acc]
    })

  echo list.fold(from: 0, over: vals |> string.split("\n"), with: fn(acc, v) {
    let assert Ok(n) = int.parse(v)
    case
      ranges
      |> list.find(fn(range) { { range.0 <= n } && { range.1 >= n } })
    {
      Ok(_) -> acc + 1
      Error(_) -> acc
    }
  })
}

const input = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"
