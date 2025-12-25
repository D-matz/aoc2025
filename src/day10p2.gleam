import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn solve() {
  let lines =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [_, ..rest] = line |> string.split("]")

      let assert [buttons, ..rest] = rest |> string.concat |> string.split("{")
      let buttons =
        buttons
        |> string.replace("(", "")
        |> string.replace(")", "")
        |> string.trim()
        |> string.split(" ")

      let btns =
        list.fold([], over: buttons, with: fn(acc, num) {
          let btn =
            num
            |> string.split(",")
            |> list.map(fn(num) {
              let assert Ok(n) = int.parse(num)
              n
            })
          [btn, ..acc]
        })
      let goal =
        rest
        |> string.concat
        |> string.drop_end(1)
        |> string.split(",")
        |> list.map(fn(x) {
          let assert Ok(n) = int.parse(x)
          n
        })
      #(btns, goal)
    })

  echo list.fold(from: 0, over: lines, with: fn(total_sum, line) {
    let btns = line.0
    let goal = line.1
    //echo btns

    let btn_parity_combos =
      list.fold(
        from: dict.new(),
        over: all_combinations(btns),
        with: fn(acc, combo) {
          let parity = combo |> get_btn_parity
          let existing = acc |> dict.get(parity)
          let new = case existing {
            Error(_) -> [combo]
            Ok(others) -> [combo, ..others]
          }
          acc |> dict.insert(parity, new)
        },
      )

    let goal_lvals =
      list.fold(#(dict.new(), 0), over: goal, with: fn(acc, b) {
        let lv = acc.0 |> dict.insert(acc.1, b)
        #(lv, acc.1 + 1)
      })

    let assert Some(min) =
      parity_even_then_halve(goal_lvals.0, btn_parity_combos)
      as " must be some"
    total_sum + min
  })
}

fn parity_even_then_halve(
  lightvals: Dict(Int, Int),
  btn_parity_combos: Dict(Int, List(List(List(Int)))),
  // key by parity
  // List(Int) button
  // List(List(Int)) combo of buttons
  // List(List(List(Int))) all combos of buttons for parity
) {
  let curr_vals = lightvals |> dict.values
  let #(allzero, allgtezero) =
    list.fold(from: #(True, True), over: curr_vals, with: fn(acc, lval) {
      let az = case lval == 0 {
        True -> acc.0
        False -> False
      }
      let gtez = case lval >= 0 {
        True -> acc.1
        False -> False
      }
      #(az, gtez)
    })
  case allzero {
    True -> Some(0)
    False -> {
      case allgtezero {
        False -> None
        True -> {
          let needed_parity = lightvals |> get_lvs_parity
          //echo btn_parity_combos |> dict.keys
          //echo needed_parity
          let maybe_combos = btn_parity_combos |> dict.get(needed_parity)
          case maybe_combos {
            Error(_) -> None
            Ok(btn_combos) -> {
              //echo btn_combos
              list.fold(
                from: None,
                over: btn_combos,
                with: fn(acc_min_to_lv, btn_combo) {
                  let new_lightvals =
                    list.fold(
                      from: lightvals,
                      over: btn_combo,
                      with: fn(lvals_acc, btn) {
                        list.fold(
                          from: lvals_acc,
                          over: btn,
                          with: fn(innermost_acc, bval) {
                            let assert Ok(lval) =
                              innermost_acc |> dict.get(bval)
                            innermost_acc |> dict.insert(bval, lval - 1)
                          },
                        )
                      },
                    )
                  // echo "-------------------"
                  // echo btn_combo
                  // echo new_lightvals
                  let lvals_halved =
                    new_lightvals
                    |> dict.map_values(fn(_light, lval) { lval / 2 })
                  let recurse_min =
                    parity_even_then_halve(lvals_halved, btn_parity_combos)
                  case recurse_min {
                    None -> acc_min_to_lv
                    Some(sub_steps) -> {
                      let steps = { sub_steps * 2 } + list.length(btn_combo)
                      case acc_min_to_lv {
                        None -> Some(steps)
                        Some(curr) -> Some(int.min(steps, curr))
                      }
                    }
                  }
                },
              )
            }
          }
        }
      }
    }
  }
}

fn all_combinations(l) {
  list.fold(from: [], over: list.range(0, l |> list.length), with: fn(acc, n) {
    acc
    |> list.append(l |> list.combinations(n))
  })
}

fn get_btn_parity(btns) {
  list.fold(from: 0, over: btns, with: fn(outer_acc, btn) {
    list.fold(from: outer_acc, over: btn, with: fn(inner_acc, bval) {
      inner_acc |> int.bitwise_exclusive_or(pow_2(bval))
    })
  })
}

fn get_lvs_parity(lvs) {
  dict.fold(from: 0, over: lvs, with: fn(acc, light, value) {
    case value % 2 == 0 {
      True -> acc
      False -> acc |> int.bitwise_exclusive_or(pow_2(light))
    }
  })
}

fn pow_2(n: Int) {
  case n {
    0 -> 1
    _ -> 2 * pow_2(n - 1)
  }
}

const input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"
