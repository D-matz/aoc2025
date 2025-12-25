import gleam/int
import gleam/list
import gleam/string

type Rect {
  Rect(min_x: Int, min_y: Int, max_x: Int, max_y: Int)
}

type Point {
  Point(x: Int, y: Int)
}

type LineHoriz {
  LineHoriz(y: Int, x_min: Int, x_max: Int)
}

type LineVert {
  LineVert(x: Int, y_min: Int, y_max: Int)
}

//probably wrong in case where big rect outside green squares, like pacman with big open mouth
pub fn solve() {
  let points =
    input
    |> string.split("\n")
    |> list.map(fn(s) {
      s
      |> string.split(",")
      |> list.map(fn(x) {
        let assert Ok(n) = int.parse(x)
        n
      })
    })

  let red_tiles =
    points
    |> list.map(fn(pt) {
      let assert Ok(x) = pt |> list.first()
      let assert Ok(y) = pt |> list.last()
      Point(x:, y:)
    })

  let assert Ok(final_pt) = red_tiles |> list.reverse() |> list.first()
  let assert Ok(first_pt) = red_tiles |> list.first()

  let fst_horiz = final_pt.x != first_pt.x

  let edges =
    list.fold(
      from: #(final_pt, #([], []), fst_horiz),
      over: red_tiles,
      with: fn(acc, pt) {
        let prev = acc.0

        let tpl = case acc.2 {
          True -> #(acc.1.0, [
            LineHoriz(pt.y, int.min(pt.x, prev.x), int.max(pt.x, prev.x)),
            ..acc.1.1
          ])
          False -> #(
            [
              LineVert(pt.x, int.min(pt.y, prev.y), int.max(pt.y, prev.y)),
              ..acc.1.0
            ],
            acc.1.1,
          )
        }
        #(pt, tpl, !acc.2)
      },
    )

  let edges_vert = edges.1.0
  let edges_horiz = edges.1.1

  echo list.fold(from: 0, over: red_tiles, with: fn(outer_acc, t1) {
    list.fold(from: outer_acc, over: red_tiles, with: fn(inner_acc, t2) {
      let sz =
        { int.absolute_value(t1.x - t2.x) + 1 }
        * { int.absolute_value(t1.y - t2.y) + 1 }
      case sz > inner_acc {
        True -> {
          let #(min_x, max_x) = case t1.x < t2.x {
            True -> #(t1.x, t2.x)
            False -> #(t2.x, t1.x)
          }
          let #(min_y, max_y) = case t1.y < t2.y {
            True -> #(t1.y, t2.y)
            False -> #(t2.y, t1.y)
          }
          let rct = Rect(min_x:, min_y:, max_x:, max_y:)
          //echo "----------------"
          //echo t1
          //echo t2
          //echo sz

          case horiz_line_intersect(rct, edges_horiz) {
            Ok(_) -> {
              //echo h
              inner_acc
            }
            Error(_) ->
              case vert_line_intersect(rct, edges_vert) {
                Ok(_) -> {
                  //echo v
                  inner_acc
                }
                Error(_) -> {
                  // echo rct
                  sz
                }
              }
          }
        }
        False -> inner_acc
      }
    })
  })
}

fn horiz_line_intersect(r: Rect, es: List(LineHoriz)) {
  es
  |> list.find(fn(e) {
    e.y |> within(r.min_y, r.max_y)
    && {
      {
        e.x_min |> within(r.min_x, r.max_x)
        || e.x_max |> within(r.min_x, r.max_x)
        || { e.x_max >= r.max_x && e.x_min <= r.min_x }
      }
    }
  })
}

fn vert_line_intersect(r: Rect, es: List(LineVert)) {
  es
  |> list.find(fn(e) {
    e.x |> within(r.min_x, r.max_x)
    && {
      {
        e.y_min |> within(r.min_y, r.max_y)
        || e.y_max |> within(r.min_y, r.max_y)
        || { e.y_max >= r.max_y && e.y_min <= r.min_y }
      }
    }
  })
}

fn within(val, lower, upper) {
  lower < val && val < upper
}

const input = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"
