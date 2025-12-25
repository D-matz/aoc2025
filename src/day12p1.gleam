import gleam/dict
import gleam/int
import gleam/list
import gleam/string

pub type Space {
  Space(x: Int, y: Int, presents: dict.Dict(Int, Int))
}

pub type Point {
  Point(x: Int, y: Int)
}

pub type Shapes {
  Shapes(s: dict.Dict(Int, dict.Dict(Point, Bool)))
}

pub fn solve() {
  let assert [goals, ..shapes] = input |> string.split("\n\n") |> list.reverse()
  let spaces =
    goals
    |> string.split("\n")
    |> list.map(fn(s) {
      let assert [sz, need] = s |> string.split(": ")
      let assert [x, y] = sz |> string.split("x")
      let assert Ok(x) = x |> int.parse
      let assert Ok(y) = y |> int.parse
      let need = need |> string.split(" ")
      let z = list.range(0, need |> list.length) |> list.zip(need)
      let presents =
        list.fold(from: dict.new(), over: z, with: fn(acc, tpl) {
          let assert Ok(n) = tpl.1 |> int.parse
          acc |> dict.insert(tpl.0, n)
        })
      Space(x:, y:, presents:)
    })
  let shapes: Shapes =
    list.fold(over: shapes, from: Shapes(s: dict.new()), with: fn(acc, s) {
      let assert [n, ..lines] = s |> string.split("\n")
      let assert Ok(num) = n |> string.drop_end(1) |> int.parse
      let shape =
        list.fold(from: #(dict.new(), 0), over: lines, with: fn(outer_acc, l) {
          let d =
            list.fold(
              from: #(outer_acc.0, 0),
              over: l |> string.to_graphemes,
              with: fn(inner_acc, c) {
                let newdict = case c {
                  "#" ->
                    inner_acc.0
                    |> dict.insert(Point(x: outer_acc.1, y: inner_acc.1), True)
                  "." ->
                    inner_acc.0
                    |> dict.insert(Point(x: outer_acc.1, y: inner_acc.1), False)
                  _ -> panic
                }
                //the x and y is probably wrong but they can be rotated anyways
                #(newdict, inner_acc.1 + 1)
              },
            )
          #(d.0, outer_acc.1 + 1)
        })
      Shapes(acc.s |> dict.insert(num, shape.0))
    })
  let sizes =
    dict.fold(from: dict.new(), over: shapes.s, with: fn(acc, n, shp) {
      let total =
        dict.fold(from: 0, over: shp, with: fn(total_acc, _, v) {
          case v {
            True -> total_acc + 1
            False -> total_acc
          }
        })
      acc |> dict.insert(n, total)
    })

  echo list.fold(over: spaces, from: 0, with: fn(acc, space) {
    let area = space.x * space.y
    let num =
      dict.fold(
        from: 0,
        over: space.presents,
        with: fn(acc, which_present, how_many) {
          let assert Ok(v) = sizes |> dict.get(which_present)
          acc + { how_many * v }
        },
      )
    case num < area {
      True -> acc + 1
      False -> acc
    }
  })
}

const input = "0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2"
