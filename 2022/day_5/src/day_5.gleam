import gleam/io
import gleam/erlang/file
import gleam/string
import gleam/pair
import gleam/list
import gleam/map
import gleam/option

fn split_on_blank_line(str) {
  assert Ok(parts) = string.split_once(str, "\n\n")
  pair.map_second(parts, string.trim)
}

fn new_stacks() -> map.Map(Int, List(String)) {
  map.new()
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
  |> list.fold(
    from: new_stacks(),
    with: fn(stacks, crate_letters) {
      list.index_fold(
        over: crate_letters,
        from: stacks,
        with: fn(stacks, crate_letter, i) {
          case crate_letter {
            " " -> stacks
            _ ->
              map.update(
                stacks,
                i + 1,
                with: fn(maybe_stack) {
                  case maybe_stack {
                    option.Some(stack) -> list.append([crate_letter], stack)
                    option.None -> [crate_letter]
                  }
                },
              )
          }
        },
      )
    },
  )
}

pub fn main() {
  io.println("Hello from day_5!")

  io.println("Part 1 test")
  assert Ok(test_data) = file.read("./data/test.txt")
  let #(stacks_str, moves_str) = split_on_blank_line(test_data)

  let stacks = parse_stack_str(stacks_str)
  io.debug(stacks)

  io.println(moves_str)
}
