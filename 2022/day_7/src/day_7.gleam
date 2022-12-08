import gleam/io
import gleam/int
import gleam/string
import gleam/list
import gleam/erlang/file

pub type TerminalLine {
  Cd(dir: Directory)
  DirList
  Dir(name: String)
  File(name: String, size: Int)
}

pub type Directory {
  Root
  Up
  Directory(name: String)
}

fn parse_file_info(str) {
  io.println(str)
  assert Ok(#(bytes_str, name)) = string.split_once(str, " ")
  assert Ok(bytes) = int.parse(bytes_str)
  File(name, bytes)
}

fn parse_terminal_lines(str) {
  string.split(str, on: "\n")
  |> list.filter(fn(str) {
    str
    |> string.trim
    |> string.length > 0
  })
  |> list.map(fn(line) {
    io.println(line)
    case line {
      "$ " <> cmd ->
        case cmd {
          "ls" -> DirList
          "cd " <> target ->
            case target {
              "/" -> Cd(Root)
              ".." -> Cd(Up)
              dir_name -> Cd(Directory(dir_name))
            }
        }
      "dir " <> dir_name -> Dir(name: dir_name)
      file_info -> parse_file_info(file_info)
    }
  })
}

pub fn handle_line(stack, line: TerminalLine) {
  io.debug(stack)
  case line {
    Cd(dir) ->
      case dir {
        Root -> []
        Up -> list.drop(stack, 1)
        Directory(name) -> list.append(stack, [name])
      }
    DirList -> stack
    Dir(name) -> stack
    File(name, size) -> stack
  }
}

pub fn main() {
  io.println("Hello from day_7!")

  io.println("Part 1 test")
  assert Ok(test_data) = file.read("./data/test.txt")
  parse_terminal_lines(test_data)
  |> list.fold(from: [], with: handle_line)
  |> io.debug
}
