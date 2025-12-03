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

fn make_joltage(p: #(Int, Int)) -> Int {
  let #(a, b) = p
  string.concat([int.to_string(a), int.to_string(b)])
  |> int.parse
  |> result.unwrap(0)
}

fn find_greatest_joltage(bank: BatteryBank) -> Int {
  list.combination_pairs(bank.batteries)
  |> list.map(make_joltage)
  |> list.max(int.compare)
  |> result.unwrap(0)
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim)

  let banks = input_data |> list.map(parse_battery_bank)

  let answer = banks |> list.map(find_greatest_joltage) |> int.sum

  io.println("Part 1 answer " <> int.to_string(answer))
}
