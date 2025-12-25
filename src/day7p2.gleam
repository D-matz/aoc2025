import gleam/dict
import gleam/list
import gleam/set
import gleam/string

pub fn solve() {
  let lines = input |> string.split("\n")
  let assert [fst, ..rest] = lines

  let splitters =
    rest
    |> list.map(fn(line) {
      let #(sn, _) =
        list.fold(
          from: #(set.new(), 0),
          over: line |> string.to_graphemes(),
          with: fn(acc, item) {
            case item {
              "^" -> #(acc.0 |> set.insert(acc.1), acc.1 + 1)
              _ -> #(acc.0, acc.1 + 1)
            }
          },
        )
      sn
    })
  let first_idx =
    fst
    |> string.to_graphemes
    |> list.take_while(fn(c) { c == "." })
    |> list.length
  let starting_beam = dict.new() |> dict.insert(first_idx, 1)
  //total num splits, current beam set
  let final =
    list.fold(
      from: starting_beam,
      over: splitters,
      with: fn(beam_acc, splitter_line) {
        //echo beam_acc
        dict.fold(
          from: beam_acc,
          over: beam_acc,
          with: fn(next_beams_acc, curr_beam_k, curr_beam_v) {
            case splitter_line |> set.contains(curr_beam_k) {
              True -> {
                let left_idx = curr_beam_k - 1
                let right_idx = curr_beam_k + 1
                let left = case dict.get(next_beams_acc, left_idx) {
                  Error(_) -> 0
                  Ok(x) -> x
                }
                let right = case dict.get(next_beams_acc, right_idx) {
                  Error(_) -> 0
                  Ok(x) -> x
                }
                next_beams_acc
                |> dict.delete(curr_beam_k)
                |> dict.insert(left_idx, left + curr_beam_v)
                |> dict.insert(right_idx, right + curr_beam_v)
              }
              False -> next_beams_acc
            }
          },
        )
      },
    )
  echo dict.fold(from: 0, over: final, with: fn(acc, _, v) { acc + v })
}

const input = ".......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."
