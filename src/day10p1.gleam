import gleam/dict
import gleam/int
import gleam/list
import gleam/string

pub fn solve() {
  let lines =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [goal, ..rest] = line |> string.split("]")
      let goal =
        goal
        |> string.to_graphemes
        |> list.drop(1)
        |> list.map(fn(c) {
          case c {
            "#" -> True
            "." -> False
            _ -> panic
          }
        })
      let assert [buttons, ..] = rest |> string.concat |> string.split("{")
      let buttons =
        buttons
        |> string.replace("(", "")
        |> string.replace(")", "")
        |> string.trim()
        |> string.split(" ")
        |> list.map(fn(nums) {
          nums
          |> string.split(",")
          |> list.map(fn(num) {
            let assert Ok(n) = int.parse(num)
            n
          })
        })
      #(goal, buttons)
    })
  echo list.fold(from: 0, over: lines, with: fn(total_sum, line) {
    let goal = line.0
    let buttons = line.1

    let goal_bits =
      list.fold(from: #(0, 1), over: goal, with: fn(acc, b) {
        let acc_now = case b {
          True -> acc.0 |> int.bitwise_or(acc.1)
          False -> acc.0
        }
        #(acc_now, acc.1 * 2)
      })
    let goal_bits = goal_bits.0
    let buttons_bits =
      list.fold(from: [], over: buttons, with: fn(acc, btn) {
        let new_btn =
          list.fold(from: 0, over: btn, with: fn(btn_acc, num) {
            btn_acc |> int.bitwise_or(pow_2(num))
          })
        [new_btn, ..acc]
      })
    let explored =
      explore_indicator(dict.new(), [ButtonConfig(0, 0)], buttons_bits)
    let assert Ok(steps) = explored |> dict.get(goal_bits)
    total_sum + steps
  })
}

type ButtonConfig {
  ButtonConfig(on: Int, steps: Int)
}

fn explore_indicator(
  have_explored_already: dict.Dict(Int, Int),
  have_but_yet_to_explore: List(ButtonConfig),
  options: List(Int),
) {
  //echo "huh"
  //echo options

  case have_but_yet_to_explore {
    [curr_explore, ..rest_yet_to_explore] -> {
      let now_have_already =
        have_explored_already
        |> dict.insert(curr_explore.on, curr_explore.steps)

      let now_have_but_yet_to_explore =
        list.fold(
          from: rest_yet_to_explore,
          over: options,
          with: fn(explored_acc, opt) {
            let new_bits = curr_explore.on |> int.bitwise_exclusive_or(opt)
            case dict.get(have_explored_already, new_bits) {
              Ok(already_steps) -> {
                case already_steps > curr_explore.steps + 1 {
                  True -> [
                    ButtonConfig(on: new_bits, steps: curr_explore.steps + 1),
                    ..explored_acc
                  ]
                  False -> explored_acc
                }
              }
              Error(_) -> [
                ButtonConfig(on: new_bits, steps: curr_explore.steps + 1),
                ..explored_acc
              ]
            }
          },
        )

      explore_indicator(now_have_already, now_have_but_yet_to_explore, options)
    }
    [] -> have_explored_already
  }
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
