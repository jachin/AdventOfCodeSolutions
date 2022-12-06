import gleam/io
import gleam/erlang/file
import gleam/string
import gleam/pair
import gleam/list
import gleam/map
import gleam/option
import gleam/regex

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

type Move {
  Move(number: Int, source: Int, destination: Int)
}

fn parse_moves_str(str) {
  assert Ok(re) = regex.from_string("move ([0-9]+) from ([0-9]+) to ([0-9]+)")

  string.split(str, on: "\n")
  |> list.map(fn(line) {
    let result = regex.scan(with: re, content: line)
    assert Ok(match) = list.first(result)
    io.debug(match.submatches)
    assert Ok(number) = list.at(match.submatches, 0)
    io.debug(number)
    number
  })
  |> io.debug
}

pub fn main() {
  io.println("Hello from day_5!")

  io.println("Part 1 test")
  assert Ok(test_data) = file.read("./data/test.txt")
  let #(stacks_str, moves_str) = split_on_blank_line(test_data)

  let stacks = parse_stack_str(stacks_str)
  io.debug(stacks)

  let steps = parse_moves_str(moves_str)

  io.println(moves_str)
}
