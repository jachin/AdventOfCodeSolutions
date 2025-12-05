import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder
import stdin

type Range =
  #(Int, Int)

type DatabaseRecord {
  DatabaseRecord(is_merged: Bool, range: Range)
}

type Database =
  List(DatabaseRecord)

fn parse_range(str: String) -> Range {
  case str |> string.split("-") {
    [a, b] -> {
      case int.parse(a), int.parse(b) {
        Ok(a_int), Ok(b_int) -> #(a_int, b_int)
        _, _ -> #(0, 0)
      }
    }
    _ -> #(0, 0)
  }
}

fn in_range(id: Int, range: Range) -> Bool {
  range.0 <= id && range.1 >= id
}

fn is_fresh(ranges: List(Range), id: Int) {
  list.any(ranges, fn(r) { in_range(id, r) })
}

fn records_overlaps(record_a: DatabaseRecord, record_b: DatabaseRecord) {
  {
    record_a.range.0 >= record_b.range.0 && record_a.range.0 <= record_b.range.0
  }
  || {
    record_a.range.1 >= record_b.range.0 && record_a.range.1 <= record_b.range.1
  }
}

fn merge_records(
  record_a: DatabaseRecord,
  record_b: DatabaseRecord,
) -> DatabaseRecord {
  let a =
    [record_a.range.0, record_b.range.0, record_a.range.1, record_b.range.1]
    |> list.sort(int.compare)
  DatabaseRecord(False, #(
    list.first(a) |> result.unwrap(0),
    list.last(a) |> result.unwrap(0),
  ))
}

fn any_mergeable_ranges(database: Database) -> Bool {
  let a = list.combination_pairs(database)
  list.filter(a, fn(p) {
    let #(a, b) = p
    records_overlaps(a, b)
  })
  |> list.length
  |> echo
  list.any(a, fn(p) {
    let #(a, b) = p
    records_overlaps(a, b)
  })
}

fn find_mergeable_pairs(
  database: Database,
) -> List(#(DatabaseRecord, DatabaseRecord)) {
  let a = list.combination_pairs(database)
  list.filter(a, fn(p) {
    let #(a, b) = p
    records_overlaps(a, b)
  })
}

fn sort_records(database: Database) -> Database {
  list.sort(database, fn(r_a, r_b) { int.compare(r_a.range.0, r_b.range.0) })
}

fn not_enclosed(database: Database, record: DatabaseRecord) -> Bool {
  list.all(database, fn(r) {
    case r.range == record.range {
      True -> True
      False -> r.range.0 > record.range.0 || r.range.1 < record.range.1
    }
  })
}

fn merge_overlapping_ranges(database: Database) -> Database {
  echo list.length(database)

  case find_mergeable_pairs(database) {
    [] -> database
    mergeable_pairs -> {
      let new_records =
        list.take(mergeable_pairs, 5)
        |> list.map(fn(p) {
          let #(r1, r2) = p
          merge_records(r1, r2)
        })

      let new_database =
        list.append(new_records, database)
        |> list.unique
        |> sort_records
        |> fn(d) { list.filter(d, fn(r) { not_enclosed(d, r) }) }

      merge_overlapping_ranges(new_database)
    }
  }
}

fn record_to_size(record: DatabaseRecord) -> Int {
  { record.range.1 - record.range.0 |> int.absolute_value } + 1
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim)

  let #(ranges_str, avalible_str) =
    list.split_while(input_data, fn(s) { s != "" })

  let ranges = list.map(ranges_str, parse_range)
  let ingredient_ids = list.map(avalible_str, int.parse) |> result.values

  let answer =
    list.filter(ingredient_ids, fn(i) { is_fresh(ranges, i) }) |> list.length

  echo answer

  ranges
  |> list.map(fn(r) { DatabaseRecord(False, r) })
  |> merge_overlapping_ranges()
  |> list.map(record_to_size)
  |> list.fold(0, int.add)
  |> echo

  io.println("Hello from day_5!")
}
