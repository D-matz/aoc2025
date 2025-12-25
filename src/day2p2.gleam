import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  let pairs =
    input
    |> string.split(",")
    |> list.map(fn(s) {
      s
      |> string.split("-")
      |> list.map(fn(x) {
        let assert Ok(n) = int.parse(x)
        n
      })
    })

  echo list.fold(from: 0, over: pairs, with: fn(outer_acc, p) {
    let assert [min, max] = p
    list.fold(
      from: outer_acc,
      over: list.range(min, max),
      with: fn(inner_acc, n) {
        let chars = n |> int.to_string |> string.to_graphemes
        let len = chars |> list.length
        let check_x = check_in_str(chars)
        case len {
          1 -> inner_acc
          _ -> {
            let repeated = list.find(list.range(1, len / 2), check_x)
            case repeated {
              Ok(_) -> {
                inner_acc + n
              }
              _ -> inner_acc
            }
          }
        }
      },
    )
  })
}

fn check_in_str(in) {
  fn(n) { is_repeat(n, in) }
}

fn is_repeat(rlen: Int, in: List(String)) {
  let chunks = in |> list.sized_chunk(rlen)
  let assert Ok(a_chunk) = chunks |> list.first()
  let found_other = list.find(chunks, fn(c) { c != a_chunk })
  case found_other {
    Ok(_) -> False
    _ -> {
      //      echo chunks
      // echo rlen
      True
    }
  }
}

const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
