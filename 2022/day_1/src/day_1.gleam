import gleam/io
import gleam/string
import gleam/list
import gleam/int
import gleam/result
import gleam/erlang/file

pub fn main() {
  io.println("Hello from day_1!")
  assert Ok(contents) = file.read("./data/part_1.txt")
  let packs =
    string.split(contents, on: "\n")
    |> list.chunk(by: fn(s) { s == "" })
    |> list.filter(fn(c) { c != [""] })
    |> list.map(fn(pack) { list.map(pack, fn(ration) { int.parse(ration) }) })
    |> list.map(result.values)
    |> list.map(fn(pack) { int.sum(pack) })
    |> list.sort(by: int.compare)

  packs
  |> list.each(fn(total_weight) {
    total_weight
    |> int.to_string
    |> io.println
  })

  io.println("Part 2")

  packs
  |> list.reverse
  |> list.take(3)
  |> int.sum
  |> int.to_string
  |> io.println
}
