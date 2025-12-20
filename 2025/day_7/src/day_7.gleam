import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import stdin

type TachyonManifoldRow =
  dict.Dict(Int, Region)

type TachyonManifold =
  List(TachyonManifoldRow)

type Region {
  Start
  Empty
  Splitter
  SplitBeam
  Beam
  Off
}

type Tachyon {
  Tachyon(cords: #(Int, Int), id: Int)
}

fn parse_line(str: String) -> TachyonManifoldRow {
  str
  |> string.to_graphemes()
  |> list.index_map(fn(s, i) { #(i, grapheme_to_region(s)) })
  |> dict.from_list()
}

fn grapheme_to_region(str: String) -> Region {
  case str {
    "." -> Empty
    "S" -> Start
    "^" -> Splitter
    "|" -> Beam
    _ -> Empty
  }
}

fn tachyon_manifold_to_string(t: TachyonManifold) -> String {
  t
  |> list.map(fn(r) {
    r
    |> dict.to_list
    |> list.map(fn(s) {
      case s {
        #(_, Empty) -> "."
        #(_, Start) -> "S"
        #(_, Splitter) -> "^"
        #(_, SplitBeam) -> "↟"
        #(_, Beam) -> "|"
        #(_, Off) -> "O"
      }
    })
  })
  |> list.intersperse(["\n"])
  |> list.flatten
  |> string.concat
}

fn get_window(
  i: Int,
  prev: dict.Dict(Int, Region),
  current: dict.Dict(Int, Region),
) -> List(Region) {
  case i, i < dict.size(current) - 1 {
    0, _ ->
      [
        Ok(Off),
        dict.get(prev, i),
        dict.get(prev, i + 1),
        Ok(Off),
        dict.get(current, i),
        dict.get(current, i + 1),
      ]
      |> result.values
    _, True -> {
      [
        dict.get(prev, i - 1),
        dict.get(prev, i),
        dict.get(prev, i + 1),
        dict.get(current, i - 1),
        dict.get(current, i),
        dict.get(current, i + 1),
      ]
      |> result.values
    }
    _, False -> {
      [
        dict.get(prev, i - 1),
        dict.get(prev, i),
        Ok(Off),
        dict.get(current, i - 1),
        dict.get(current, i),
        Ok(Off),
      ]
      |> result.values
    }
  }
}

fn next_step_helper(
  prev: dict.Dict(Int, Region),
  current: dict.Dict(Int, Region),
) -> dict.Dict(Int, Region) {
  current
  |> dict.to_list
  |> list.index_map(fn(_, i) {
    let window = get_window(i, prev, current)
    case window {
      [_, _, _, _, Start, _] -> #(i, Start)
      [_, Start, _, _, Empty, _] -> #(i, Beam)
      [_, Beam, _, _, Empty, _] -> #(i, Beam)
      [_, Empty, _, _, Splitter, _] -> #(i, Splitter)
      [_, Beam, _, _, Splitter, _] -> #(i, SplitBeam)
      [_, Empty, Beam, _, Empty, Splitter] -> #(i, Beam)
      [Beam, _, _, Splitter, Empty, _] -> #(i, Beam)
      _ -> #(i, Empty)
    }
  })
  |> dict.from_list()
}

fn next_step(
  new_manifold: TachyonManifold,
  current_row: dict.Dict(Int, Region),
  i: Int,
) -> TachyonManifold {
  case i {
    0 -> {
      [current_row]
    }
    _ -> {
      case list.last(new_manifold) {
        Ok(last_step) -> {
          list.append(new_manifold, [
            next_step_helper(last_step, current_row),
          ])
        }
        Error(_) -> []
      }
    }
  }
}

fn is_beam_split(r: List(#(Int, Region))) -> Bool {
  case r {
    [#(_, Beam), #(_, SplitBeam), #(_, Beam)] -> True
    _ -> False
  }
}

fn is_start(_: Int, r: Region) {
  case r {
    Start -> True
    _ -> False
  }
}

fn tally_tachyons(tachyons: List(Tachyon)) -> Int {
  list.fold(tachyons, 0, fn(n, t) { t.id + n })
}

fn merge_tachyons_helper(tachyons: List(Tachyon)) -> Tachyon {
  case tachyons {
    [] -> Tachyon(#(0, 0), 0)
    [t] -> t
    [t, ..] -> Tachyon(t.cords, tally_tachyons(tachyons))
  }
}

fn merge_tachyons(tachyons: List(Tachyon)) -> List(Tachyon) {
  tachyons
  |> list.chunk(fn(t) { t.cords.0 })
  |> list.map(fn(ts) { merge_tachyons_helper(ts) })
}

fn path_walker(manifold: TachyonManifold) -> List(Tachyon) {
  let first = list.first(manifold) |> result.unwrap(dict.new())
  let rest = list.rest(manifold) |> result.unwrap([])

  let initial_row =
    dict.filter(first, is_start)
    |> fn(r) {
      let assert Ok(#(i, _)) = r |> dict.to_list |> list.first
      [Tachyon(#(i, 0), 1)]
    }

  rest |> list.fold(initial_row, walk_step)
}

fn walk_step(tachyons: List(Tachyon), row: TachyonManifoldRow) -> List(Tachyon) {
  echo tachyons |> list.length
  tachyons
  |> merge_tachyons
  |> list.fold([], fn(ts, t) {
    case dict.get(row, t.cords.0) {
      Ok(SplitBeam) -> {
        let t1 = Tachyon(#(t.cords.0 - 1, t.cords.1 + 1), t.id)
        let t2 = Tachyon(#(t.cords.0 + 1, t.cords.1 + 1), t.id)
        [t1, t2, ..ts]
      }
      Ok(Beam) -> {
        let t1 = Tachyon(#(t.cords.0, t.cords.1 + 1), t.id)
        [t1, ..ts]
      }
      _ -> ts
    }
  })
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim)
    |> list.map(parse_line)

  io.println(input_data |> tachyon_manifold_to_string)

  let manifold = list.index_fold(input_data, [], next_step)

  io.println("")

  io.println(manifold |> tachyon_manifold_to_string)
  let a =
    manifold
    |> list.map(fn(row) {
      list.window(row |> dict.to_list, 3)
      |> list.filter(is_beam_split)
      |> list.length
    })
    |> int.sum

  echo a
  // gflambe.apply(
  //   fn() {
  //     path_walker(manifold) |> list.length |> echo
  //     io.println("")
  //   },
  //   [
  //     gflambe.OutputFormat(gflambe.BrendanGregg),
  //   ],
  // )

  path_walker(manifold) |> tally_tachyons |> echo

  io.println("")
}
