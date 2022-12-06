import gleam/io
import gleam/erlang/file
import gleam/string
import gleam/pair
import gleam/list
import gleam/map
import gleam/option
import gleam/regex
import gleam/int

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
                    option.Some(stack) -> list.append(stack, [crate_letter])
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

fn option_str_to_int(option_str) {
  option.map(
    over: option_str,
    with: fn(str) { option.from_result(int.parse(str)) },
  )
  |> option.flatten
  |> option.unwrap(-1)
}

fn parse_moves_str(str) {
  assert Ok(re) = regex.from_string("move ([0-9]+) from ([0-9]+) to ([0-9]+)")

  string.split(str, on: "\n")
  |> list.map(fn(line) {
    let result = regex.scan(with: re, content: line)
    assert Ok(match) = list.first(result)
    assert Ok(number_option) = list.at(match.submatches, 0)
    assert Ok(source_option) = list.at(match.submatches, 1)
    assert Ok(destination_option) = list.at(match.submatches, 2)

    Move(
      number: number_option
      |> option_str_to_int,
      source: source_option
      |> option_str_to_int,
      destination: destination_option
      |> option_str_to_int,
    )
  })
}

fn lift_crates_9000(stacks, move: Move) {
  assert Ok(source_stack) = map.get(stacks, move.source)
  assert Ok(destination_stack) = map.get(stacks, move.destination)
  let #(moving, rest) = list.split(list: source_stack, at: move.number)
  map.insert(stacks, move.source, rest)
  |> map.insert(
    move.destination,
    list.append(
      moving
      |> list.reverse,
      destination_stack,
    ),
  )
}

fn lift_crates_9001(stacks, move: Move) {
  assert Ok(source_stack) = map.get(stacks, move.source)
  assert Ok(destination_stack) = map.get(stacks, move.destination)
  let #(moving, rest) = list.split(list: source_stack, at: move.number)
  map.insert(stacks, move.source, rest)
  |> map.insert(move.destination, list.append(moving, destination_stack))
}

fn top_crates(stacks) {
  map.values(stacks)
  |> list.map(fn(stack) {
    case list.first(stack) {
      Ok(c) -> c
      _ -> " "
    }
  })
  |> string.concat
}

pub fn main() {
  io.println("Hello from day_5!")

  io.println("Part 1 test")
  assert Ok(test_data) = file.read("./data/test.txt")
  let #(stacks_str, moves_str) = split_on_blank_line(test_data)
  let stacks = parse_stack_str(stacks_str)
  let steps = parse_moves_str(moves_str)
  let finished_stack = list.fold(steps, stacks, lift_crates_9000)
  io.println(top_crates(finished_stack))

  io.println("Part 1")
  assert Ok(data) = file.read("./data/part_1.txt")
  let #(stacks_str, moves_str) = split_on_blank_line(data)
  let stacks = parse_stack_str(stacks_str)
  let steps = parse_moves_str(moves_str)
  let finished_stack = list.fold(steps, stacks, lift_crates_9000)
  io.println(top_crates(finished_stack))

  io.println("Part 2 test")
  assert Ok(test_data) = file.read("./data/test.txt")
  let #(stacks_str, moves_str) = split_on_blank_line(test_data)
  let stacks = parse_stack_str(stacks_str)
  let steps = parse_moves_str(moves_str)
  let finished_stack = list.fold(steps, stacks, lift_crates_9001)
  io.println(top_crates(finished_stack))

  io.println("Part 2")
  assert Ok(test_data) = file.read("./data/part_1.txt")
  let #(stacks_str, moves_str) = split_on_blank_line(test_data)
  let stacks = parse_stack_str(stacks_str)
  let steps = parse_moves_str(moves_str)
  let finished_stack = list.fold(steps, stacks, lift_crates_9001)
  io.println(top_crates(finished_stack))
}
