import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import stdin

type BatteryBank {
  BatteryBank(batteries: List(Int))
}

fn parse_battery_bank(str: String) -> BatteryBank {
  string.to_graphemes(str)
  |> list.map(int.parse)
  |> result.values
  |> BatteryBank
}

fn find_greatest_joltage(bank: BatteryBank) -> Int {
  find_highest_digit_for_battery_n(bank.batteries, 12) |> make_joltage
}

fn find_highest_digit(batteries: List(Int)) -> #(Int, List(Int)) {
  let #(h_index, h_value) =
    list.index_fold(batteries, #(0, 0), fn(a, bv, bi) {
      let #(ai, av) = a
      case bv > av {
        True -> #(bi, bv)
        False -> #(ai, av)
      }
    })

  let #(_, rest) = list.split(batteries, h_index + 1)

  #(h_value, rest)
}

fn find_highest_digit_for_battery_n(
  remaining_batteries: List(Int),
  n: Int,
) -> List(Int) {
  case n > 0 {
    True -> {
      let #(search_space, rest) =
        list.split(
          remaining_batteries,
          list.length(remaining_batteries) - n + 1,
        )

      let #(v, leftover_search_space) = find_highest_digit(search_space)
      let new_search_space = list.append(leftover_search_space, rest)

      list.append(
        [v],
        find_highest_digit_for_battery_n(new_search_space, n - 1),
      )
    }
    False -> []
  }
}

fn make_joltage(b: List(Int)) -> Int {
  b
  |> list.map(int.to_string)
  |> string.concat()
  |> int.parse
  |> result.unwrap(0)
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim)

  let banks = input_data |> list.map(parse_battery_bank)

  let answer = banks |> list.map(find_greatest_joltage) |> int.sum

  io.println("Part 2 answer " <> int.to_string(answer))
}
