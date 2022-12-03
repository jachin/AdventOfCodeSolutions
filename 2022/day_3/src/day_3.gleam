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

pub fn find_duplicate_item(nap_sack_strs) {
  list.map(
    nap_sack_strs,
    fn(nap_sack_str) {
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
    },
  )
}

pub fn main() {
  io.println("Hello from day_3!")
  io.println("Part 1 Test")
  assert Ok(test_data) = file.read("./data/test.txt")
  parse_data_into_lines(test_data)
  |> find_duplicate_item
  |> list.map(item_to_priority)
  |> int.sum
  |> int.to_string
  |> io.println

  io.println("Part 1")
  assert Ok(data_1) = file.read("./data/part_1.txt")

  parse_data_into_lines(data_1)
  |> find_duplicate_item
  |> list.map(item_to_priority)
  |> int.sum
  |> int.to_string
  |> io.println
}
