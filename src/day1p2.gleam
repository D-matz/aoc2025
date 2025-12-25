import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  let steps = string.split(input, "\n")
  //counter, currentrotation
  echo list.fold(over: steps, from: #(0, 50), with: rotate_add)
}

fn rotate_add(acc: #(Int, Int), rotation: String) {
  case string.to_graphemes(rotation) {
    [] -> acc
    [r, ..num] -> {
      let assert Ok(numint) = int.parse(string.concat(num))
      let current_ctr = acc.0
      let current_rotation = acc.1
      let new_rotation =
        case r {
          "R" -> current_rotation + numint
          "L" -> current_rotation - numint
          _ -> current_rotation
        }
        |> propermod(100)
      let modh = int.absolute_value(numint / 100)
      let ctr_numhundreds = modh
      let ctr_modspasszero = case current_rotation {
        0 -> 0
        _ ->
          case r {
            "R" ->
              case current_rotation + propermod(numint, 100) >= 100 {
                True -> 1
                False -> 0
              }
            "L" ->
              case current_rotation - propermod(numint, 100) <= 0 {
                True -> 1
                False -> 0
              }
            _ -> 0
          }
      }
      //io.println(rotation <> " " <> int.to_string(ctr_modspasszero))
      let new_ctr = current_ctr + ctr_numhundreds + ctr_modspasszero
      //echo rotation
      #(new_ctr, new_rotation)
    }
  }
}

fn propermod(num: Int, divisor: Int) {
  let assert Ok(n) = int.modulo(num, divisor)
  n
}

const input = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"
