import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import stdin

// fn invert(a: List(List(String))) -> List(List(String)) {
//   let l = list.first(a) |> result.unwrap([]) |> list.length
//   let p = list.flatten(a)
//   list.index_fold(p, [], fn(c, i) {

//   })
// }
fn solve(a: List(String)) {
  let operator =
    list.first(a)
    |> result.unwrap("")
    |> string.reverse
    |> string.first
    |> result.unwrap("")
  let numbers =
    a
    |> list.map(fn(s) { string.replace(s, "+", "") })
    |> list.map(fn(s) { string.replace(s, "*", "") })
    |> list.map(string.trim)
    |> list.map(int.parse)
    |> result.values
  case operator {
    "+" -> int.sum(numbers)
    "*" -> list.fold(numbers, 1, int.multiply)
    _ -> 0
  }
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim_end)
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(string.concat)
    |> list.map(string.trim)
    |> list.chunk(string.is_empty)
    |> list.filter(fn(l) { l != [""] })

  echo input_data |> list.map(solve) |> int.sum

  io.println("Hello from day_6!")
}
