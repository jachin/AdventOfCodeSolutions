import gleam/io
import gleam/int
import gleam/map
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

type File =
  #(String, String)

pub type FileSystem {
  FileSystem(stack: List(String), files: map.Map(File, Int))
}

fn new_file_system() {
  FileSystem([], map.new())
}

fn go_to_root(file_system: FileSystem) {
  FileSystem([], files: file_system.files)
}

fn go_up_dir(file_system: FileSystem) {
  FileSystem(list.drop(file_system.stack, 1), file_system.files)
}

fn go_down_dir(file_system: FileSystem, dir_name: String) {
  FileSystem(list.append(file_system.stack, [dir_name]), file_system.files)
}

fn add_file(file_system: FileSystem, file_name: String, file_size: Int) {
  FileSystem(
    file_system.stack,
    case list.length(file_system.stack) < 1 {
      True -> map.insert(file_system.files, #("/", file_name), file_size)
      False ->
        map.insert(
          file_system.files,
          #(string.join(file_system.stack, "/"), file_name),
          file_size,
        )
    },
  )
}

fn parse_file_info(str) {
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

pub fn handle_line(file_system: FileSystem, line: TerminalLine) {
  case line {
    Cd(dir) ->
      case dir {
        Root -> go_to_root(file_system)
        Up -> go_up_dir(file_system)
        Directory(name) -> go_down_dir(file_system, name)
      }
    DirList -> file_system
    Dir(_) -> file_system
    File(name, size) -> add_file(file_system, name, size)
  }
}

fn calculate_dir_sizes(file_system: FileSystem) {
  file_system.files
  |> map.to_list
  |> list.fold(from: [], with: fn(file, size) {
      let dir 
    })
  |> io.debug
}

pub fn main() {
  io.println("Hello from day_7!")

  io.println("Part 1 test")
  assert Ok(test_data) = file.read("./data/test.txt")
  parse_terminal_lines(test_data)
  |> list.fold(from: new_file_system(), with: handle_line)
  |> calculate_dir_sizes
  |> io.debug
}
