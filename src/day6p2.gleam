import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  let split =
    input
    |> string.split("\n")
    |> list.map(string.to_graphemes)
    |> list.transpose
  //echo split
  //total list of cols together and current cols building up, with op
  let idk =
    list.fold(from: #([], []), over: split, with: fn(acc, col) {
      let all_spaces = list.find(col, fn(x) { x != " " })
      case all_spaces {
        Ok(_) -> #(acc.0, [col, ..acc.1])
        //acc.1 |> list.reverse maybe not needed since + and * dont care order but nicer
        Error(_) -> #([acc.1 |> list.reverse, ..acc.0], [])
      }
    })

  let total_inputs = [idk.1 |> list.reverse, ..idk.0] |> list.reverse
  echo list.fold(from: 0, over: total_inputs, with: fn(grand_total_acc, nums) {
    let assert Ok(fst) = nums |> list.first
    let assert Ok(op) = fst |> list.reverse |> list.first
    let concat_nums =
      nums
      |> list.map(fn(l) {
        let assert Ok(n) =
          l
          |> list.filter(fn(x) { x != " " && x != "*" && x != "+" })
          |> string.concat
          |> int.parse()
        n
      })
    grand_total_acc
    + case op {
      "*" -> list.fold(from: 1, over: concat_nums, with: fn(acc, x) { acc * x })
      "+" -> list.fold(from: 0, over: concat_nums, with: fn(acc, x) { acc + x })
      _ -> panic
    }
  })
  //now need to split into digits
  //64
  //23
  //314
  //-> 4, 431, 623
}

const input = "123 328  51 64
 45 64  387 23
  6 98  215 314
*   +   *   +  "
