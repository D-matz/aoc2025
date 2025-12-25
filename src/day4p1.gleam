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
          "@" -> 1
          "." -> 0
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

  let idx_paper = d.0
  echo dict.fold(from: 0, over: idx_paper, with: fn(forklift_acc, key, value) {
    case value {
      1 -> {
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
                Ok(x) -> adj_acc + x
              }
            },
          )
        case adj < 4 {
          True -> forklift_acc + 1
          False -> forklift_acc
        }
      }
      0 -> forklift_acc
      _ -> panic
    }
  })
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
