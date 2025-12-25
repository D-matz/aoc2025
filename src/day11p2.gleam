import gleam/dict
import gleam/list
import gleam/string

// each eee or whatever has list of nodes that go to it
pub type Froms {
  Froms(from: dict.Dict(String, List(String)))
}

// the string coming to out and the number of times from there
// eee 2 from ggg and ggg has bbb ccc -> eee add 2 from bbb and ccc
pub type NumToOut {
  NumToOut(n: dict.Dict(String, Int))
}

pub fn solve() {
  let lines =
    list.fold(
      from: Froms(from: dict.new()),
      over: input |> string.split("\n"),
      with: fn(acc, line) {
        let assert [node, rest] = line |> string.split(":")
        let list_to = rest |> string.trim() |> string.split(" ")

        list.fold(from: acc, over: list_to, with: fn(inner_acc, to) {
          let curr = inner_acc.from |> dict.get(to)
          let curr_dict = case curr {
            Ok(nodes_to) -> nodes_to
            Error(_) -> []
          }
          Froms(from: inner_acc.from |> dict.insert(to, [node, ..curr_dict]))
        })
      },
    )

  let svr_fft = paths("svr", "fft", lines)
  let fft_dac = paths("fft", "dac", lines)
  let dac_out = paths("dac", "out", lines)
  echo svr_fft * fft_dac * dac_out
}

fn paths(from_node: String, to_node: String, lines: Froms) {
  let assert Ok(out) = dict.get(lines.from, to_node)
  let d =
    list.fold(from: dict.new(), over: out, with: fn(acc, s) {
      acc |> dict.insert(s, 1)
    })
  // making "you" a node not from any other nodes
  // so next_paths_to stops there
  let paths_from = Froms(from: lines.from |> dict.delete(from_node))
  let start = NumToOut(n: d)
  //echo paths_from
  let p = next_paths_to(start, paths_from)
  let assert Ok(n) = p.n |> dict.get(from_node)
  n
}

fn next_paths_to(node: NumToOut, paths: Froms) {
  //echo "-------------------------------"
  //echo node.n
  let new_nums =
    dict.fold(
      from: NumToOut(n: dict.new()),
      over: node.n,
      with: fn(acc, try_from_key, try_from_value) {
        //echo paths.from |> dict.get(try_from_key)
        case paths.from |> dict.get(try_from_key) {
          Error(_) -> {
            let curr = acc.n |> dict.get(try_from_key)
            let curr_num = case curr {
              Ok(x) -> x
              Error(_) -> 0
            }
            let paths_now = curr_num + try_from_value
            NumToOut(n: acc.n |> dict.insert(try_from_key, paths_now))
          }

          Ok(ps) -> {
            list.fold(from: acc, over: ps, with: fn(inner_acc, p) {
              let curr = inner_acc.n |> dict.get(p)
              let curr_num = case curr {
                Ok(x) -> x
                Error(_) -> 0
              }
              let paths_now = curr_num + try_from_value
              NumToOut(n: inner_acc.n |> dict.insert(p, paths_now))
            })
          }
        }
      },
    )
  //have a node that isnt a starting node in the list to check
  let still_have_paths =
    new_nums.n
    |> dict.keys
    |> list.find(fn(node) {
      node != "you"
      && {
        case paths.from |> dict.get(node) {
          Ok(_) -> True
          Error(_) -> False
        }
      }
    })
  //echo still_have_paths
  case still_have_paths {
    Ok(_) -> next_paths_to(new_nums, paths)
    Error(_) -> new_nums
  }
}

const input = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out"
