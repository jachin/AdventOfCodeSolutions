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
    "X" -> Ok(Lose)
    "Y" -> Ok(Draw)
    "Z" -> Ok(Win)
    _ -> Error(Nil)
  }
}

fn calculate_strategy(data: #(Play, Goal)) {
  case data.0 {
    Rock ->
      case data.1 {
        Lose -> 3 + 0
        Draw -> 1 + 3
        Win -> 2 + 6
      }

    Paper ->
      case data.1 {
        Lose -> 1 + 0
        Draw -> 2 + 3
        Win -> 3 + 6
      }

    Scissors ->
      case data.1 {
        Lose -> 2 + 0
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

fn str_to_play_2(str) {
  case str {
    "A" -> Ok(Rock)
    "B" -> Ok(Paper)
    "C" -> Ok(Scissors)

    _ -> Error(Nil)
  }
}

fn parse_data_2(str) {
  string.split(str, on: "\n")
  |> list.map(fn(line) { string.split(line, on: " ") })
  |> list.map(fn(chunks) {
    assert Ok(play_str) = list.first(chunks)
    assert Ok(goal_str) = list.last(chunks)
    assert Ok(play) = str_to_play_2(play_str)
    assert Ok(goal) = str_to_goal(goal_str)
    #(play, goal)
  })
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

  io.println("Part 2 test")
  parse_data_2(test_data)
  |> list.map(calculate_strategy)
  |> int.sum
  |> int.to_string
  |> io.println

  io.println("Part 2")
  parse_data_2(part_1_data)
  |> list.map(calculate_strategy)
  |> int.sum
  |> int.to_string
  |> io.println
}
