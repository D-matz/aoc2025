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
  //let assert Ok(vals) = split |> list.last()

  //new approach: keep a set of ranges
  //if new range overlaps with one, make them into one big range

  let ranges =
    list.fold(
      from: [],
      over: ranges |> string.split("\n"),
      with: fn(ranges_acc, r) {
        let range_split = r |> string.split("-")
        let assert Ok(Ok(start)) =
          range_split |> list.first() |> result.map(int.parse)
        let assert Ok(Ok(end)) =
          range_split |> list.last() |> result.map(int.parse)
        insert_new_range(#(start, end), ranges_acc, [])
      },
    )

  echo list.fold(from: 0, over: ranges, with: fn(acc, range) {
    acc + 1 + range.1 - range.0
  })
}

fn insert_new_range(
  newrange: #(Int, Int),
  old_list: List(#(Int, Int)),
  new_list: List(#(Int, Int)),
) {
  case old_list {
    [] -> [newrange, ..new_list]
    [first_old, ..rest_old] -> {
      case newrange.0 > first_old.1, newrange.1 < first_old.0 {
        False, False -> {
          //need to join the two ranges
          let joined_range = #(
            int.min(newrange.0, first_old.0),
            int.max(newrange.1, first_old.1),
          )
          //joined the newrange with first_old so dont need first_old, ..new_list
          insert_new_range(joined_range, rest_old, new_list)
        }
        _, _ -> insert_new_range(newrange, rest_old, [first_old, ..new_list])
      }
    }
  }
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
