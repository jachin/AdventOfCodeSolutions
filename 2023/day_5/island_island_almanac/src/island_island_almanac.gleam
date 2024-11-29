import gleam/io
import gleam/result
import simplifile


pub fn main() {
  io.println("Hello from island_island_almanac!")
  result.map(over: simplifile.read(from: "./sample.txt"), with: fn(line) {io.println(line)})

}
