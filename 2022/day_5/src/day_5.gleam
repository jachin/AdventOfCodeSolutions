import gleam/io
import gleam/erlang/file
import gleam/string
import gleam/pair
import gleam/list
import gleam/map

fn split_on_blank_line(str) {
  assert Ok(parts) = string.split_once(str, "\n\n")
  pair.map_second(parts, string.trim)
}

fn parse_stack_str(str) {
  string.split(str, on: "\n")
  |> list.map(string.to_graphemes)
  |> list.map(fn(line_list) { list.sized_chunk(line_list, into: 4) })
  |> list.map(fn(row) {
    list.map(
      row,
      fn(str_pieces) {
        assert Ok(crate_letter) = list.at(str_pieces, 1)
        crate_letter
      },
    )
  })
  |> list.reverse
  |> list.drop(1)
  |> list.reverse
  |> list.index_map(fn(i, crate_letter) { crate_letter })
  |> io.debug
}

pub fn main() {
  io.println("Hello from day_5!")

  io.println("Part 1 test")
  assert Ok(test_data) = file.read("./data/test.txt")
  let #(stacks_str, moves_str) = split_on_blank_line(test_data)
  io.println(stacks_str)
  io.println(moves_str)
  parse_stack_str(stacks_str)
}
