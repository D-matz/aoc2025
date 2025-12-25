import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  let split = input |> string.split("\n")
  let lines = split |> list.reverse() |> list.drop(1) |> list.reverse()
  let assert Ok(ops) = split |> list.last()
  let rows =
    lines
    |> list.map(fn(row) {
      row
      |> string.split(" ")
      |> list.filter(fn(x) { x != "" })
      |> list.map(fn(x) {
        let assert Ok(n) = int.parse(x)
        n
      })
    })
  let col_ops = ops |> string.split(" ") |> list.filter(fn(x) { x != "" })
  let cols = rows |> list.transpose()

  echo list.fold(
    from: 0,
    over: list.zip(cols, col_ops),
    with: fn(acc, vals_and_op) {
      acc
      + case vals_and_op.1 {
        "+" ->
          list.fold(from: 0, over: vals_and_op.0, with: fn(add_acc, val) {
            add_acc + val
          })
        "*" ->
          list.fold(from: 1, over: vals_and_op.0, with: fn(mul_acc, val) {
            mul_acc * val
          })
        _ -> panic
      }
    },
  )
}

const input = "123 328  51 64
 45 64  387 23
  6 98  215 314
*   +   *   +  "
