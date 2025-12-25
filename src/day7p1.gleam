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
  let starting_beam = set.new() |> set.insert(first_idx)
  //total num splits, current beam set
  echo list.fold(
    from: #(0, starting_beam),
    over: splitters,
    with: fn(beam_acc, splitter_line) {
      set.fold(
        from: #(beam_acc.0, beam_acc.1),
        over: beam_acc.1,
        with: fn(curr_acc, curr_idx) {
          case splitter_line |> set.contains(curr_idx) {
            True -> {
              let newbeams =
                curr_acc.1
                |> set.insert(curr_idx + 1)
                |> set.insert(curr_idx - 1)
                |> set.delete(curr_idx)
              #(curr_acc.0 + 1, newbeams)
            }
            False -> #(curr_acc.0, curr_acc.1)
          }
        },
      )
    },
  )
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
