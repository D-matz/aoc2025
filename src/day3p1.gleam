import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  echo input |> string.split("\n") |> list.fold(from: 0, with: get_larget)
}

fn get_larget(acc: Int, str: String) {
  let split1: List(String) = string.to_graphemes(str)
  let no_last_char: List(String) =
    str |> string.drop_end(1) |> string.to_graphemes
  let assert Ok(max1) = list.max(no_last_char, string.compare)
  let split2: List(String) =
    list.drop_while(split1, fn(x) { x != max1 }) |> list.drop(1)
  let assert Ok(max2) = list.max(split2, string.compare)
  let assert Ok(add) = int.parse(max1 <> max2)
  acc + add
}

const input = "987654321111111
811111111111119
234234234234278
818181911112111"
