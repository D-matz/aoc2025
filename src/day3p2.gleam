import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  echo input
    |> string.split("\n")
    |> list.fold(from: 0, with: fn(acc, s) {
      let assert Ok(row_num) = get_digit_n("", 12, s) |> int.parse()
      //echo s
      //echo row_num
      acc + row_num
    })
}

fn get_digit_n(acc_str: String, n: Int, from_digits: String) {
  //io.println(from_digits)
  case n {
    0 -> acc_str
    _ -> {
      let mx =
        from_digits
        |> string.drop_end(n - 1)
        |> string.to_graphemes()
        |> list.max(string.compare)
      // io.println("can pick from " <> from_digits |> string.drop_end(n - 1))
      let max = case mx {
        Error(_) -> {
          panic as "huh"
        }
        Ok(x) -> x
      }
      // io.println("use mx " <> max)
      let new_digits =
        from_digits
        |> string.to_graphemes()
        |> list.drop_while(fn(x) { x != max })
      let assert Ok(digit) = list.first(new_digits) as "why"
      let taken_digit = new_digits |> list.drop(1)
      get_digit_n(acc_str <> digit, n - 1, string.concat(taken_digit))
    }
  }
}

const input = "987654321111111
811111111111119
234234234234278
818181911112111"
