import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import stdin

type Space {
  Empty
  PaperRoll
}

fn is_empty(s: Space) -> Bool {
  case s {
    Empty -> True
    PaperRoll -> False
  }
}

type Grid =
  List(#(Cords, Space))

type Cords =
  #(Int, Int)

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

fn identity(x) {
  x
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim)
  let grid = parse_input(input_data)
  let answer =
    grid
    |> list.map(fn(grid_space) {
      let #(cords, _) = grid_space
      has_4_empty_spaces(grid, cords)
    })
    |> list.filter(identity)
    |> list.length
  echo answer
  io.println("Hello from day_4!")
}
