import gleam/io
import gleam/erlang/file
import gleam/string
import gleam/list
import gleam/int
import gleam/iterator
import gleam/set

type Assignment {
  Assignment(zones: set.Set(Int))
}

type AssignmentPair {
  AssignmentPair(first: Assignment, second: Assignment)
}

fn parse_data(str) {
  string.split(str, on: "\n")
  |> list.filter(fn(line) { string.length(line) > 0 })
  |> list.map(fn(line) { string.split(line, on: ",") })
  |> list.map(fn(pair) { list.map(pair, fn(p) { string.split(p, on: "-") }) })
  |> list.map(fn(pair) {
    list.map(
      pair,
      fn(p) {
        list.map(
          p,
          fn(p_str) {
            assert Ok(p_int) = int.parse(p_str)
            p_int
          },
        )
      },
    )
  })
}

fn make_sets(data) {
  list.map(
    data,
    fn(pair) {
      assert Ok(first) = list.at(pair, 0)
      assert Ok(second) = list.at(pair, 1)

      assert Ok(first_start) = list.at(first, 0)
      assert Ok(first_end) = list.at(first, 1)

      assert Ok(second_start) = list.at(second, 0)
      assert Ok(second_end) = list.at(second, 1)

      AssignmentPair(
        Assignment(
          iterator.range(first_start, first_end)
          |> iterator.to_list
          |> set.from_list,
        ),
        Assignment(
          iterator.range(second_start, second_end)
          |> iterator.to_list
          |> set.from_list,
        ),
      )
    },
  )
}

fn is_redundant(data: List(AssignmentPair)) {
  list.map(
    data,
    fn(pair) {
      case
        set.size(pair.first.zones) < set.union(
          pair.first.zones,
          pair.second.zones,
        )
        |> set.size,
        set.size(pair.second.zones) < set.union(
          pair.first.zones,
          pair.second.zones,
        )
        |> set.size
      {
        True, True -> False
        _, _ -> True
      }
    },
  )
}

pub fn main() {
  io.println("Hello from day_4!")

  io.println("Part 1 test")
  assert Ok(test_data) = file.read("./data/test.txt")
  parse_data(test_data)
  |> make_sets
  |> is_redundant
  |> list.filter(fn(b) { b })
  |> list.length
  |> int.to_string
  |> io.println

  io.println("Part 1")
  assert Ok(part_1_data) = file.read("./data/part_1.txt")
  parse_data(part_1_data)
  |> make_sets
  |> is_redundant
  |> list.filter(fn(b) { b })
  |> list.length
  |> int.to_string
  |> io.println
}
