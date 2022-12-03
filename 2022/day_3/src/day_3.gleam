import gleam/io
import gleam/int
import gleam/list
import gleam/set
import gleam/string
import gleam/erlang/file

fn parse_data_into_lines(str) {
  string.split(str, on: "\n")
  |> list.filter(fn(line) { string.length(line) > 0 })
}

fn item_to_priority(str) {
  case str {
    "a" -> 1
    "b" -> 2
    "c" -> 3
    "d" -> 4
    "e" -> 5
    "f" -> 6
    "g" -> 7
    "h" -> 8
    "i" -> 9
    "j" -> 10
    "k" -> 11
    "l" -> 12
    "m" -> 13
    "n" -> 14
    "o" -> 15
    "p" -> 16
    "q" -> 17
    "r" -> 18
    "s" -> 19
    "t" -> 20
    "u" -> 21
    "v" -> 22
    "w" -> 23
    "x" -> 24
    "y" -> 25
    "z" -> 26
    "A" -> 27
    "B" -> 28
    "C" -> 29
    "D" -> 30
    "E" -> 31
    "F" -> 32
    "G" -> 33
    "H" -> 34
    "I" -> 35
    "J" -> 36
    "K" -> 37
    "L" -> 38
    "M" -> 39
    "N" -> 40
    "O" -> 41
    "P" -> 42
    "Q" -> 43
    "R" -> 44
    "S" -> 45
    "T" -> 46
    "U" -> 47
    "V" -> 48
    "W" -> 49
    "X" -> 50
    "Y" -> 51
    "Z" -> 52
    _ -> -1
  }
}

fn find_duplicate_items(nap_sack_strs) {
  list.map(nap_sack_strs, find_duplicate_item)
}

fn find_duplicate_item(nap_sack_str) {
  let compartment_1 =
    string.slice(
      from: nap_sack_str,
      at_index: 0,
      length: string.length(nap_sack_str) / 2,
    )
    |> string.to_graphemes
    |> set.from_list
  let compartment_2 =
    string.slice(
      from: nap_sack_str,
      at_index: string.length(nap_sack_str) / 2,
      length: string.length(nap_sack_str) / 2,
    )
    |> string.to_graphemes
    |> set.from_list
  assert Ok(duplicate_item) =
    set.intersection(compartment_1, compartment_2)
    |> set.to_list
    |> list.first
  duplicate_item
}

fn find_shared_item(nap_sack_strs) {
  let nap_sack_sets =
    nap_sack_strs
    |> list.map(fn(nap_sack_str) {
      nap_sack_str
      |> string.to_graphemes
      |> set.from_list
    })

  assert Ok(first_nap_sack) = list.first(nap_sack_sets)
  assert Ok(rest_nap_sacks) = list.rest(nap_sack_sets)
  let common_item_as_set =
    list.fold(
      over: rest_nap_sacks,
      from: first_nap_sack,
      with: set.intersection,
    )
  assert Ok(common_item) =
    common_item_as_set
    |> set.to_list
    |> list.first
  common_item
}

pub fn main() {
  io.println("Hello from day_3!")
  io.println("Part 1 Test")
  assert Ok(test_data) = file.read("./data/test.txt")
  parse_data_into_lines(test_data)
  |> find_duplicate_items
  |> list.map(item_to_priority)
  |> int.sum
  |> int.to_string
  |> io.println

  io.println("Part 1")
  assert Ok(data_1) = file.read("./data/part_1.txt")

  parse_data_into_lines(data_1)
  |> find_duplicate_items
  |> list.map(item_to_priority)
  |> int.sum
  |> int.to_string
  |> io.println

  io.println("Part 2 Test")
  assert Ok(test_data) = file.read("./data/test.txt")
  parse_data_into_lines(test_data)
  |> list.sized_chunk(into: 3)
  |> list.map(fn(group) {
    group
    |> find_shared_item
  })
  |> list.map(item_to_priority)
  |> int.sum
  |> int.to_string
  |> io.println

  io.println("Part 2")
  assert Ok(data_2) = file.read("./data/part_1.txt")
  parse_data_into_lines(data_2)
  |> list.sized_chunk(into: 3)
  |> list.map(fn(group) {
    group
    |> find_shared_item
  })
  |> list.map(item_to_priority)
  |> int.sum
  |> int.to_string
  |> io.println
}
