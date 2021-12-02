import Cocoa

var greeting = "Hello, playground"

enum Direction {
  case forward
  case down
  case up
  case nothing
}

struct Instruction {
  var direction = Direction.nothing
  var units = 0
}

func loadInstructionsFromFile(fileName: String) -> [Instruction] {
  if let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt") {
    if let fileContents = try? String(contentsOf: fileUrl) {
      let lines = fileContents.split(separator: "\n")
      return lines.map {
        
        let parts = $0.split(separator: " ")
        if (parts.count < 2) {
          return Instruction(direction: Direction.nothing, units: 0)
        }
        let d = parts[0]
        let n = Int(parts[1])!
        
        if (d.hasPrefix("forward")) {
          return Instruction(direction: Direction.forward, units: n)
        } else if (d.hasPrefix("down")) {
          return Instruction(direction: Direction.down, units: n)
        } else if (d.hasPrefix("up")) {
          return Instruction(direction: Direction.up, units: n)
        } else {
          return Instruction()
        }
      }
    }
  }
  return []
}

func calculatePosition(instructions: [Instruction]) -> Int {
  var h = 0
  var d = 0
  for instruction in instructions {
    switch instruction.direction {
    case .nothing:
      break
    case .forward:
      h += instruction.units
    case .down:
      d += instruction.units
    case .up:
      d -= instruction.units
      if d < 0 {
          d = 0
    
      }
    }
  }
  return h * d
}

func calculatePositionPart2(instructions: [Instruction]) -> Int {
  var h = 0
  var d = 0
  var a = 0
  for instruction in instructions {
    switch instruction.direction {
    case .nothing:
      break
    case .forward:
      h += instruction.units
      d += a * instruction.units
    case .down:
      a += instruction.units
    case .up:
      a -= instruction.units
    }
  }
  return h * d
}

let exampleInstructions = loadInstructionsFromFile(fileName: "example")
print(calculatePosition(instructions: exampleInstructions))
print(calculatePositionPart2(instructions: exampleInstructions))

let puzzel1Instructions = loadInstructionsFromFile(fileName: "puzzle_input")
print(calculatePosition(instructions: puzzel1Instructions))
print(calculatePositionPart2(instructions: puzzel1Instructions))
