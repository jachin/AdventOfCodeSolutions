import gleam/io
import gleam/list
import gleam/string
import gleam/yielder
import stdin

type Space {
  Empty
  PaperRoll
}

type Grid =
  List(#(Cords, Space))

type Cords =
  #(Int, Int)

fn is_empty(s: Space) -> Bool {
  case s {
    Empty -> True
    PaperRoll -> False
  }
}

fn string_to_space(str: String) -> Space {
  case str {
    "." -> Empty
    "@" -> PaperRoll
    _ -> Empty
  }
}

fn parse_input(input: List(String)) -> Grid {
  input
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes()
    |> list.index_map(fn(g, x) { #(#(y, x), string_to_space(g)) })
  })
  |> list.flatten
}

fn get_space(grid: Grid, cords: Cords) {
  case list.key_find(grid, cords) {
    Ok(space) -> space
    Error(_) -> Empty
  }
}

fn cord_up_left(cords: Cords) {
  #(cords.0 - 1, cords.1 - 1)
}

fn cord_up(cords: Cords) {
  #(cords.0, cords.1 - 1)
}

fn cord_up_right(cords: Cords) {
  #(cords.0 + 1, cords.1 - 1)
}

fn cord_right(cords: Cords) {
  #(cords.0 + 1, cords.1)
}

fn cord_down_right(cords: Cords) {
  #(cords.0 + 1, cords.1 + 1)
}

fn cord_down(cords: Cords) {
  #(cords.0, cords.1 + 1)
}

fn cord_down_left(cords: Cords) {
  #(cords.0 - 1, cords.1 + 1)
}

fn cord_left(cords: Cords) {
  #(cords.0 - 1, cords.1)
}

fn get_space_and_neighbors(grid: Grid, cords: Cords) -> #(Space, List(Space)) {
  #(get_space(grid, cords), [
    get_space(grid, cord_up_left(cords)),
    get_space(grid, cord_up(cords)),
    get_space(grid, cord_up_right(cords)),
    get_space(grid, cord_right(cords)),
    get_space(grid, cord_down_right(cords)),
    get_space(grid, cord_down(cords)),
    get_space(grid, cord_down_left(cords)),
    get_space(grid, cord_left(cords)),
  ])
}

fn has_4_empty_spaces(grid: Grid, cords: Cords) {
  let #(space, neighbors) = get_space_and_neighbors(grid, cords)
  case space {
    Empty -> False
    PaperRoll -> {
      neighbors |> list.filter(is_empty) |> list.length > 4
    }
  }
}

fn remove_rolls(grid: Grid, rolls_to_move: Grid) -> Grid {
  grid
  |> list.map(fn(g) {
    let #(cords, space) = g
    case space {
      Empty -> g
      PaperRoll ->
        case list.key_find(rolls_to_move, cords) {
          Ok(_) -> #(cords, Empty)
          Error(_) -> g
        }
    }
  })
}

fn get_next_grid(grid: Grid) -> #(Int, Grid) {
  let rolls_to_move =
    grid
    |> list.filter(fn(grid_space) {
      let #(cords, _) = grid_space
      has_4_empty_spaces(grid, cords)
    })
  #(list.length(rolls_to_move), remove_rolls(grid, rolls_to_move))
}

fn find_answer(rolls_removed: Int, grid: Grid) -> #(Int, Grid) {
  let #(next_rolls_removed, next_grid) = get_next_grid(grid)
  echo next_rolls_removed
  case next_rolls_removed == 0 {
    True -> #(rolls_removed, grid)
    False -> find_answer(next_rolls_removed + rolls_removed, next_grid)
  }
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim)
  let grid = parse_input(input_data)

  let answer = find_answer(0, grid)

  echo answer
  io.println("Hello from day_4!")
}
