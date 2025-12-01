import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/string
import gleam/yielder
import stdin

type Rotation {
  Left(Int)
  Right(Int)
}

fn parse_rotation_string(str) -> Option(Rotation) {
  case string.trim(str) {
    "L" <> num_str ->
      case int.parse(num_str) {
        Ok(num) -> Some(Left(num))
        Error(_) -> None
      }
    "R" <> num_str ->
      case int.parse(num_str) {
        Ok(num) -> Some(Right(num))
        Error(_) -> None
      }
    _ -> None
  }
}

fn turn_helper(state: #(Int, Int), rotation: Rotation) -> #(Int, Int) {
  let #(dial_state, zeros) = state
  case rotation {
    Left(n) ->
      case n {
        0 -> state
        _ ->
          case int.compare(dial_state - 1, 0) {
            order.Lt -> turn_helper(#(99, zeros), Left(n - 1))
            order.Eq -> turn_helper(#(dial_state - 1, zeros + 1), Left(n - 1))
            order.Gt -> turn_helper(#(dial_state - 1, zeros), Left(n - 1))
          }
      }
    Right(n) ->
      case n {
        0 -> state
        _ ->
          case int.compare(dial_state + 1, 99) {
            order.Lt -> turn_helper(#(dial_state + 1, zeros), Right(n - 1))
            order.Eq -> turn_helper(#(dial_state + 1, zeros), Right(n - 1))
            order.Gt -> turn_helper(#(0, zeros + 1), Right(n - 1))
          }
      }
  }
}

fn turns_past_zero(state: #(Int, Int), rotation: Rotation) -> #(Int, Int) {
  turn_helper(state, rotation)
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> string.join("\n")
    |> string.trim()

  let rotations =
    string.split(input_data, "\n")
    |> list.map(parse_rotation_string)
    |> option.values

  let #(_, zeros) = list.fold(rotations, #(50, 0), turns_past_zero)

  io.println("Hello from day_1! " <> int.to_string(zeros))
}
