import gleam/io
import gleam/string
import gleam/erlang/file
import gleam/list
import gleam/int
import gleam/option

pub type Play {
  Rock
  Paper
  Scissors
}

pub type Goal {
  Lose
  Draw
  Win
}

pub type Game {
  Move(them: Play, us: Play)
}

fn calculate_score(game) {
  case game {
    Move(them, us) ->
      case us {
        Rock ->
          case them {
            Rock -> 1 + 3
            Paper -> 1 + 0
            Scissors -> 1 + 6
          }
        Paper ->
          case them {
            Rock -> 2 + 6
            Paper -> 2 + 3
            Scissors -> 2 + 0
          }
        Scissors ->
          case them {
            Rock -> 3 + 0
            Paper -> 3 + 6
            Scissors -> 3 + 3
          }
      }
  }
}

fn str_to_play(str) {
  case str {
    "A" -> option.Some(Rock)
    "B" -> option.Some(Paper)
    "C" -> option.Some(Scissors)
    "X" -> option.Some(Rock)
    "Y" -> option.Some(Paper)
    "Z" -> option.Some(Scissors)
    _ -> option.None
  }
}

fn str_to_goal(str) {
  case str {
    "X" -> option.Some(Lose)
    "Y" -> option.Some(Draw)
    "Z" -> option.Some(Win)
    _ -> option.None
  }
}

fn calculate_strategy(play, goal) {
  case play {
    Rock ->
      case Goal {
        Lose -> 3 + 1
        Draw -> 1 + 3
        Win -> 2 + 6
      }

    Paper ->
      case Goal {
        Lose -> 1 + 1
        Draw -> 2 + 3
        Win -> 3 + 6
      }

    Scissors ->
      case Goal {
        Lose -> 2 + 1
        Draw -> 3 + 3
        Win -> 1 + 6
      }
  }
}

fn parse_data(str) {
  string.split(str, on: "\n")
  |> list.map(fn(line) { string.split(line, on: " ") })
  |> list.map(fn(chunks) {
    case list.first(chunks), list.last(chunks) {
      Ok(them_str), Ok(us_str) ->
        case str_to_play(them_str), str_to_play(us_str) {
          option.Some(them_play), option.Some(us_play) ->
            option.Some(Move(them_play, us_play))
          _, _ -> option.None
        }

      _, _ -> option.None
    }
  })
  |> option.values
}

pub fn main() {
  io.println("Part 1 test")

  assert Ok(test_data) = file.read("./data/test.txt")
  parse_data(test_data)
  |> list.map(calculate_score)
  |> int.sum
  |> int.to_string
  |> io.println

  io.println("Part 1")
  assert Ok(part_1_data) = file.read("./data/part_1.txt")
  parse_data(part_1_data)
  |> list.map(calculate_score)
  |> int.sum
  |> int.to_string
  |> io.println
}
