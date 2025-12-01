import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/string

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

fn turn_helper(dial_state: Int, rotation: Rotation) -> Int {
  case rotation {
    Left(n) ->
      case n {
        0 -> dial_state
        _ ->
          case int.compare(dial_state - 1, 0) {
            order.Lt -> turn_helper(99, Left(n - 1))
            order.Eq -> turn_helper(dial_state - 1, Left(n - 1))
            order.Gt -> turn_helper(dial_state - 1, Left(n - 1))
          }
      }
    Right(n) ->
      case n {
        0 -> dial_state
        _ ->
          case int.compare(dial_state + 1, 99) {
            order.Lt -> turn_helper(dial_state + 1, Right(n - 1))
            order.Eq -> turn_helper(dial_state + 1, Right(n - 1))
            order.Gt -> turn_helper(0, Right(n - 1))
          }
      }
  }
}

fn turn(dial_state: Int, rotation: Rotation) -> Int {
  echo rotation
  turn_helper(dial_state, rotation)
}

fn turn_to_zero(state: #(Int, Int), rotation: Rotation) -> #(Int, Int) {
  let #(dial_state, zeros) = state
  let new_dial_state = turn(dial_state, rotation)
  echo new_dial_state
  case new_dial_state {
    0 -> #(new_dial_state, zeros + 1)
    _ -> #(new_dial_state, zeros)
  }
}

pub fn main() -> Nil {
  let part_1_test_data =
    "L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82"

  let rotations =
    string.split(part_1_test_data, "\n")
    |> list.map(parse_rotation_string)
    |> echo
    |> option.values

  let #(_, zeros) = list.fold(rotations, #(50, 0), turn_to_zero)

  io.println("Hello from day_1! " <> int.to_string(zeros))
}
