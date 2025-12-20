import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleam/yielder
import stdin

type Junction =
  #(Int, Int, Int)

type Circut =
  List(Junction)

fn parse_line(str: String) -> Result(Junction, Nil) {
  let numbers =
    str
    |> string.split(",")
    |> list.map(int.parse)

  case numbers {
    [Ok(x), Ok(y), Ok(z)] -> Ok(#(x, y, z))
    _ -> Error(Nil)
  }
}

fn distance(a: Junction, b: Junction) -> Result(Int, Nil) {
  case
    int.power(a.0 - b.0, 2.0),
    int.power(a.1 - b.1, 2.0),
    int.power(a.2 - b.2, 2.0)
  {
    Ok(x), Ok(y), Ok(z) ->
      float.square_root(x +. y +. z) |> result.map(float.round)
    _, _, _ -> Error(Nil)
  }
}

fn distance_pair(p: #(Junction, Junction)) -> Result(Int, Nil) {
  let #(a, b) = p
  distance(a, b)
}

fn all_distances(
  junction_boxes: List(Junction),
) -> List(#(Int, Junction, Junction)) {
  list.combination_pairs(junction_boxes)
  |> list.map(fn(jp) {
    case distance_pair(jp) {
      Ok(distance) -> Ok(#(distance, jp.0, jp.1))
      Error(_) -> Error(Nil)
    }
  })
  |> result.values
  |> list.sort(
    fn(djp_a: #(Int, Junction, Junction), djp_b: #(Int, Junction, Junction)) {
      int.compare(djp_a.0, djp_b.0)
    },
  )
}

fn is_junction_in_circut(j: Junction, c: Circut) -> Bool {
  list.contains(c, j)
}

fn find_circut_with_junction(
  circuts: List(Circut),
  junction: Junction,
) -> Result(#(Circut, List(Circut)), Nil) {
  case list.partition(circuts, fn(c) { is_junction_in_circut(junction, c) }) {
    #([], _) -> Error(Nil)
    #([c], rest) -> Ok(#(c, rest))
    _ -> Error(Nil)
  }
}

fn combine_juction_circuts(
  j_a: Junction,
  j_b: Junction,
  circuts: List(Circut),
) -> Result(List(Circut), Nil) {
  find_circut_with_junction(circuts, j_a)
  |> result.map(fn(r1) {
    let #(c1, rest) = r1
    find_circut_with_junction(rest, j_b)
    |> result.map(fn(r2) {
      let #(c2, rest2) = r2
      [list.append(c1, c2), ..rest2]
    })
  })
  |> result.flatten
}

fn combine_all_circults(
  distances: List(#(Int, Junction, Junction)),
  circuts: List(Circut),
  last_distance: option.Option(#(Int, Junction, Junction)),
) -> #(option.Option(#(Int, Junction, Junction)), List(Circut)) {
  // echo list.length(distances)
  case list.split(distances, 1) {
    #([d], rest) -> {
      let #(_, j_a, j_b) = d
      case combine_juction_circuts(j_a, j_b, circuts) {
        Ok(new_curcuts) -> {
          combine_all_circults(rest, new_curcuts, option.Some(d))
        }
        Error(_) -> combine_all_circults(rest, circuts, last_distance)
      }
    }
    _ -> #(last_distance, circuts)
  }
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> list.map(string.trim)
    |> list.map(parse_line)
    |> result.values

  let distances = all_distances(input_data)
  let circuts = list.map(input_data, fn(j) { [j] })

  echo distances |> list.length
  echo circuts |> list.length

  let #(last_distance, _) =
    combine_all_circults(distances, circuts, option.None)

  case last_distance {
    option.Some(d) -> echo d.1.0 * d.2.0
    option.None -> {
      echo "something went wrong"
      0
    }
  }

  io.println("Hello from day_8!")
}
