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

type PathNode {
  PathNode(region: Region, cords: #(Int, Int))
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

fn path_walker(manifold: TachyonManifold) -> List(List(PathNode)) {
  let first = list.first(manifold) |> result.unwrap([])
  let rest = list.rest(manifold) |> result.unwrap([])

  list.index_map(first, fn(r, i) {
    case r {
      Start -> walk_step(rest, [PathNode(Start, #(i, 0))], i, 0)
      _ -> []
    }
  })
  |> list.flatten
}

fn walk_step(
  manifold: TachyonManifold,
  current_path: List(PathNode),
  beam_index: Int,
  depth: Int,
) -> List(List(PathNode)) {
  // echo #(beam_index, depth)
  case list.first(manifold), list.rest(manifold) {
    Error(Nil), Error(Nil) -> {
      [current_path]
    }
    Ok(row), Ok(rest) -> {
      case at(row, beam_index) {
        SplitBeam -> {
          let splitter = PathNode(SplitBeam, cords: #(beam_index, depth))
          let left = PathNode(Beam, cords: #(beam_index - 1, depth))
          let right = PathNode(Beam, cords: #(beam_index + 1, depth))
          let left_path = list.append(current_path, [splitter, left])
          let right_path = list.append(current_path, [splitter, right])
          list.append(
            walk_step(rest, left_path, beam_index - 1, depth + 1),
            walk_step(rest, right_path, beam_index + 1, depth + 1),
          )
        }
        Beam -> {
          let splitter = PathNode(Beam, cords: #(beam_index, depth))
          let left_path = list.append(current_path, [splitter])
          walk_step(rest, left_path, beam_index, depth + 1)
        }
        _ -> [current_path]
      }
    }
    Ok(_), Error(Nil) -> []
    _, _ -> []
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

  path_walker(manifold) |> list.length |> echo

  io.println("")
}
