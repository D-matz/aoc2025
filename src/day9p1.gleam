import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  let points =
    input
    |> string.split("\n")
    |> list.map(fn(s) {
      s
      |> string.split(",")
      |> list.map(fn(x) {
        let assert Ok(n) = int.parse(x)
        n
      })
    })
  echo list.fold(from: 0, over: points, with: fn(outer_acc, pt) {
    let assert [x1, y1] = pt
    list.fold(from: outer_acc, over: points, with: fn(inner_acc, other_pt) {
      let assert [x2, y2] = other_pt
      let sz =
        { int.absolute_value(x2 - x1) + 1 }
        * { int.absolute_value(y2 - y1) + 1 }
      case sz > inner_acc {
        True -> sz
        False -> inner_acc
      }
    })
  })
}

const input = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"
