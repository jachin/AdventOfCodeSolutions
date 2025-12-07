import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import stdin

fn parse_lines(str: String) {
  string.split(str, " ")
  |> list.map(string.trim)
  |> list.filter(fn(s) { !string.is_empty(s) })
}

fn invert(equations: List(List(String))) -> List(#(#(Int, Int), String)) {
  equations
  |> list.index_fold([], fn(acc1, line, i) {
    let a =
      line
      |> list.index_map(fn(term, j) { #(#(i, j), term) })
    list.append(acc1, a)
  })
}

fn get_dimension(equations: List(List(String))) -> #(Int, Int) {
  #(
    list.first(equations) |> result.unwrap([]) |> list.length,
    list.length(equations),
  )
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim)
    |> list.map(parse_lines)

  echo input_data

  let input_data_as_pairs = invert(input_data)

  echo get_dimension(input_data)

  let dimension = get_dimension(input_data)

  let input_data_as_row =
    list.fold(list.range(0, dimension.0 - 1), [], fn(acc, i) {
      list.append(
        acc,
        list.map(list.range(0, dimension.1 - 1), fn(j) {
          echo list.key_find(input_data_as_pairs, #(j, i))
        }),
      )
    })
    |> result.values

  echo input_data_as_row

  echo list.fold(input_data_as_row, #([], 0), fn(acc, term) {
    let #(stack, total) = acc
    case term {
      "+" -> echo #([], int.sum(stack) + total)
      "*" -> echo #([], list.fold(stack, 1, int.multiply) + total)
      i ->
        case int.parse(i) {
          Ok(n) -> echo #(list.append(stack, [n]), total)
          Error(_) -> #(stack, total)
        }
    }
  })

  io.println("Hello from day_6!")
}
