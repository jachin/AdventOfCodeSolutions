import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder
import stdin

type TachyonManifold =
  List(List(Region))

type Region {
  Start
  Empty
  Splitter
  SplitBeam
  Beam
  Off
}

fn parse_line(str: String) -> List(Region) {
  str |> string.to_graphemes() |> list.map(grapheme_to_region)
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
    list.map(r, fn(s) {
      case s {
        Empty -> "."
        Start -> "S"
        Splitter -> "^"
        SplitBeam -> "↟"
        Beam -> "|"
        Off -> "O"
      }
    })
  })
  |> list.intersperse(["\n"])
  |> list.flatten
  |> string.concat
}

fn at(l: List(Region), i: Int) -> Region {
  list.split(l, i) |> pair.second |> list.first |> result.unwrap(Off)
}

fn get_window(i: Int, prev: List(Region), current: List(Region)) -> List(Region) {
  case i, i < list.length(current) - 1 {
    0, _ -> [
      at(prev, i - 1),
      at(prev, i),
      at(prev, i + 1),
      Off,
      at(current, i),
      at(current, i + 1),
    ]
    _, True -> {
      [
        at(prev, i - 1),
        at(prev, i),
        at(prev, i + 1),
        at(current, i - 1),
        at(current, i),
        at(current, i + 1),
      ]
    }
    _, False -> {
      [
        at(prev, i - 1),
        at(prev, i),
        at(prev, i + 1),
        at(current, i - 1),
        at(current, i),
        Off,
      ]
    }
  }
}

fn next_step_helper(prev: List(Region), current: List(Region)) -> List(Region) {
  list.index_map(current, fn(_, i) {
    let window = get_window(i, prev, current)
    case window {
      [_, _, _, _, Start, _] -> Start
      [_, Start, _, _, Empty, _] -> Beam
      [_, Beam, _, _, Empty, _] -> Beam
      [_, Empty, _, _, Splitter, _] -> Splitter
      [_, Beam, _, _, Splitter, _] -> SplitBeam
      [_, Empty, Beam, _, Empty, Splitter] -> Beam
      [Beam, _, _, Splitter, Empty, _] -> Beam
      _ -> Empty
    }
  })
}

fn next_step(
  new_manifold: TachyonManifold,
  current_row: List(Region),
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

fn is_beam_split(r: List(Region)) -> Bool {
  case r {
    [Beam, SplitBeam, Beam] -> True
    _ -> False
  }
}

fn find_multiple_worlds(manifold: TachyonManifold) -> Int {
  let first = list.first(manifold) |> result.unwrap([])
  let rest = list.rest(manifold) |> result.unwrap([])

  list.index_map(first, fn(r, i) {
    case r {
      Start -> find_multiple_worlds_helper(rest, i, 0)
      _ -> 0
    }
  })
  |> int.sum
}

fn find_multiple_worlds_helper(
  manifold: TachyonManifold,
  beam_index: Int,
  depth: Int,
) -> Int {
  // echo #(depth, beam_index)
  case list.first(manifold), list.rest(manifold) {
    Error(Nil), Error(Nil) -> {
      1
    }
    Ok(row), Ok(rest) -> {
      case at(row, beam_index) {
        Start -> 0
        Empty -> 0
        Splitter -> 0
        SplitBeam ->
          find_multiple_worlds_helper(rest, beam_index - 1, depth + 1)
          + find_multiple_worlds_helper(rest, beam_index + 1, depth + 1)
        Beam -> find_multiple_worlds_helper(rest, beam_index, depth + 1)
        Off -> 0
      }
    }
    Ok(row), Error(Nil) -> {
      case at(row, beam_index) {
        SplitBeam -> 0
        Beam -> 1
        _ -> 0
      }
    }
    _, _ -> 0
  }
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
      list.window(row, 3) |> list.filter(is_beam_split) |> list.length
    })
    |> int.sum

  echo a

  echo find_multiple_worlds(manifold)

  io.println("")
}
