import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  let inputs = string.split(input, ",")
  echo list.fold(over: inputs, from: 0, with: fn(invalid_acc, code) {
    case string.split(code, "-") {
      [first, last] -> {
        let assert Ok(f_int) = int.parse(first)
        let assert Ok(l_int) = int.parse(last)
        let range = list.range(f_int, l_int)
        let range_invalid_sum =
          list.fold(over: range, from: 0, with: num_has_seq)
        invalid_acc + range_invalid_sum
      }
      _ -> panic
    }
  })
}

fn num_has_seq(acc: Int, x: Int) {
  let digits = x |> int.to_string |> string.to_graphemes
  let len = list.length(digits)
  let try_seqlens = list.range(2, len / 2)
  let digits_cmp_fnc = str_has_seq(digits)
  let ret = case list.any(try_seqlens, digits_cmp_fnc) {
    False -> acc
    True -> {
      //io.println("invalid " <> int.to_string(x))
      acc + x
    }
  }
  //io.println(string.concat(digits) <> " " <> int.to_string(acc))
  ret
}

fn str_has_seq(str1: List(String)) {
  fn(len2: Int) -> Bool { some_str_has_sq(str1, len2) }
}

//takes digits and seq len and returns if it's a repeated sequence or not
fn some_str_has_sq(digits: List(String), seq_len: Int) -> Bool {
  //io.println("digits " <> string.concat(digits) <> " try seq len " <> int.to_string(seq_len))
  let chunks = list.sized_chunk(digits, seq_len)
  let assert Ok(first_chunk) = list.first(chunks)
  let cmp_fnc = cmp_some_str(first_chunk)
  case list.length(first_chunk) * 2 == list.length(digits) {
    True -> {
      case list.find(chunks, cmp_fnc) {
        Ok(_) -> False
        Error(_) -> True
        //cant find any chunk not equal to first one
      }
    }
    False -> False
  }
}

fn cmp_some_str(str1: List(String)) -> fn(List(String)) -> Bool {
  fn(str2: List(String)) -> Bool { str1 != str2 }
}

const input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
