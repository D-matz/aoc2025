import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/set
import gleam/string

pub fn solve() {
  let points =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.split(",")
      |> list.map(fn(x) {
        let assert Ok(n) = int.parse(x)
        n
      })
    })
  let distances =
    list.fold(from: #([], points), over: points, with: fn(acc, pt) {
      let assert [_, ..after] = acc.1
      let assert [x1, y1, z1] = pt
      let point_distances =
        list.fold(from: acc.0, over: after, with: fn(newdists_acc, pt2) {
          let assert [x2, y2, z2] = pt2
          let assert Ok(newdist) =
            int.square_root(
              { { x2 - x1 } * { x2 - x1 } }
              + { { y2 - y1 } * { y2 - y1 } }
              + { { z2 - z1 } * { z2 - z1 } },
            )
          let newd = dict.new() |> dict.insert(newdist, #(pt, pt2))
          [newd, ..newdists_acc]
        })
      #(point_distances, after)
    })
  let connect =
    distances.0
    |> list.sort(fn(d1, d2) {
      let l1 = dict.to_list(d1)
      let assert Ok(k1) = l1 |> list.first()
      let l2 = dict.to_list(d2)
      let assert Ok(k2) = l2 |> list.first()
      float.compare(k1.0, k2.0)
    })
  let circuits =
    points
    |> list.map(fn(p) { set.new() |> set.insert(p) })
  list.fold(from: circuits, over: connect, with: fn(acc, connect_pts) {
    let d = dict.to_list(connect_pts)
    let assert Ok(pts) = d |> list.last()
    let assert [set1] =
      acc
      |> list.filter(fn(s) { s |> set.contains(pts.1.0) })
    let assert [set2] =
      acc
      |> list.filter(fn(s) { s |> set.contains(pts.1.1) })
    //echo set1
    //echo set2
    let list_without_connected =
      acc
      |> list.filter(fn(s) {
        !{ s |> set.contains(pts.1.0) } && !{ s |> set.contains(pts.1.1) }
      })
    //echo set.union(set1, set2)
    let conn = [set.union(set1, set2), ..list_without_connected]
    case list.length(conn) {
      1 -> {
        let assert Ok(x1) = pts.1.0 |> list.first
        let assert Ok(x2) = pts.1.1 |> list.first
        echo x1 * x2
        panic as "done"
      }
      _ -> conn
    }
  })
}

const input = "162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"
