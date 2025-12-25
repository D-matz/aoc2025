import gleam/dict
import gleam/list
import gleam/string

pub type Indexes {
  Indexes(i: Int, j: Int)
}

pub fn solve() {
  let split =
    input
    |> string.split("\n")
    |> list.map(string.to_graphemes)
    |> list.map(fn(cs) {
      cs
      |> list.map(fn(c) {
        case c {
          "@" -> True
          "." -> False
          _ -> panic as "lolidk"
        }
      })
    })

  let d =
    list.fold(from: #(dict.new(), 0), over: split, with: fn(col_acc, bs) {
      let row =
        list.fold(from: #(dict.new(), 0), over: bs, with: fn(row_acc, b) {
          let idx = Indexes(col_acc.1, row_acc.1)
          let rowentry = dict.insert(into: row_acc.0, for: idx, insert: b)
          #(rowentry, { row_acc.1 + 1 })
        })
      let newdict = dict.merge(col_acc.0, row.0)
      #(newdict, { col_acc.1 + 1 })
    })

  let all_possible_removed = remove_papers(d.0, 0)
  echo all_possible_removed.1
}

fn remove_papers(idx_paper: dict.Dict(Indexes, Bool), total_removed: Int) {
  let #(newdict, num_removed) =
    dict.fold(
      from: #(dict.new(), 0),
      over: idx_paper,
      with: fn(forklift_acc, key, value) {
        case value {
          True -> {
            let adj =
              list.fold(
                from: 0,
                over: [
                  #(-1, -1),
                  #(-1, 0),
                  #(-1, 1),
                  #(0, -1),
                  #(0, 1),
                  #(1, -1),
                  #(1, 0),
                  #(1, 1),
                ],
                with: fn(adj_acc, check_idxs) {
                  case
                    dict.get(
                      idx_paper,
                      Indexes(key.i - check_idxs.0, key.j - check_idxs.1),
                    )
                  {
                    Error(_) -> adj_acc
                    Ok(x) ->
                      case x {
                        True -> adj_acc + 1
                        False -> adj_acc
                      }
                  }
                },
              )
            case adj < 4 {
              True -> #(
                dict.insert(into: forklift_acc.0, for: key, insert: False),
                forklift_acc.1 + 1,
              )
              False -> #(
                dict.insert(into: forklift_acc.0, for: key, insert: True),
                forklift_acc.1,
              )
            }
          }
          False -> #(
            dict.insert(into: forklift_acc.0, for: key, insert: False),
            forklift_acc.1,
          )
        }
      },
    )
  case num_removed {
    0 -> #(newdict, total_removed)
    _ -> remove_papers(newdict, total_removed + num_removed)
  }
}

const input = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."
