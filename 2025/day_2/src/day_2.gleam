import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/yielder
import stdin

type ProductRange {
  ProductRange(start: Int, end: Int)
}

fn parse_product_ranges(input: String) -> Option(ProductRange) {
  case string.split(input, "-") {
    [first_str, second_str] ->
      case int.parse(first_str), int.parse(second_str) {
        Ok(first), Ok(second) -> Some(ProductRange(first, second))
        _, _ -> None
      }
    _ -> None
  }
}

// fn is_invalid_product_helper(len: Int, str: String) -> Bool {
//   case len <= string.length(str) / 2, string.length(str) % len == 0 {
//     True, True -> {
//       let sub_str = string.slice(str, 0, len)
//       let r = string.length(str) / len
//       let test_str = string.repeat(sub_str, r)
//       case test_str == str {
//         True -> True
//         False -> is_invalid_product_helper(len + 1, str)
//       }
//     }
//     True, False -> {
//       is_invalid_product_helper(len + 1, str)
//     }
//     False, True -> False
//     False, False -> False
//   }
// }

fn is_invalid_product(product_id: String) -> Bool {
  let l = string.length(product_id)
  let h = l / 2
  let sub_str = string.slice(product_id, 0, h)
  let test_str = string.repeat(sub_str, 2)
  case l % 2 == 0, test_str == product_id {
    False, _ -> False
    True, True -> True
    True, False -> False
  }
}

fn find_invalid_products(p: ProductRange) -> List(Int) {
  list.range(p.start, p.end)
  |> list.map(int.to_string)
  |> list.filter(is_invalid_product)
  |> list.map(int.parse)
  |> result.values
}

pub fn main() -> Nil {
  let input_data =
    stdin.read_lines()
    |> yielder.to_list()
    |> string.join("\n")
    |> string.trim()

  let product_ranges =
    string.split(input_data, ",")
    |> list.map(parse_product_ranges)
    |> option.values()

  echo product_ranges

  let total =
    product_ranges
    |> list.map(find_invalid_products)
    |> list.flatten
    |> echo
    |> int.sum

  io.println("Part 1 answer " <> int.to_string(total))
}
