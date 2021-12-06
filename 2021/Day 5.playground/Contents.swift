import Cocoa

class VentLine {
  var x1 = 0
  var y1 = 0
  var x2 = 0
  var y2 = 0
  
  func isStraight() -> Bool {
    return self.x1 == self.x2 || self.y1 == self.y2
  }
  
  func points() -> [(Int, Int)] {
    if x1 == x2 {
      if (self.y1 < self.y2) {
        return (self.y1...self.y2).map { (self.x1, $0) }
      } else {
        return (self.y2...self.y1).map { (self.x1, $0) }
      }
      
    } else if y1 == y2 {
      if (self.x1 < self.x2) {
        return (self.x1...self.x2).map { ( $0, self.y1 ) }
      } else {
        return (self.x2...self.x1).map { ( $0, self.y1 ) }
      }
      
    } else {
      if (self.x1 < self.x2 && self.y1 < self.y2) {
        let xs = self.x1...self.x2
        let ys = self.y1...self.y2
        return Array(zip(xs, ys))
      } else if (self.x1 >= self.x2 && self.y1 < self.y2) {
        let xs = (self.x2...self.x1).reversed()
        let ys = self.y1...self.y2
        return Array(zip(xs, ys))
      } else if (self.x1 < self.x2 && self.y1 >= self.y2) {
        let xs = self.x1...self.x2
        let ys = (self.y2...self.y1).reversed()
        return Array(zip(xs, ys))
      } else {
        let xs = self.x2...self.x1
        let ys = self.y2...self.y1
        return Array(zip(xs, ys))
      }
    }
  }
}

func stringToVentLine(line: String) -> VentLine {
  let pieces = line.split(separator: " ")
  let start = pieces[0]
  let end = pieces[2]
  let ventLine = VentLine()
  let oneParts = start.split(separator: ",").map { Int($0)! }
  let twoParts = end.split(separator: ",").map { Int($0)! }
  ventLine.x1 = oneParts[0]
  ventLine.y1 = oneParts[1]
  ventLine.x2 = twoParts[0]
  ventLine.y2 = twoParts[1]
  return ventLine
}


func loadLinesFromFile(fileName: String) -> [VentLine] {
  let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt")!
  let fileContents = try! String(contentsOf: fileUrl)
  let lines = fileContents.split(separator: "\n")
  return lines.map { stringToVentLine(line: String($0)) }
}

func findOceanFloorSize(ventLines: [VentLine]) -> (Int, Int) {
  var xMax = 0
  var yMax = 0
  for line in ventLines {
    if (line.x1 > xMax) {
      xMax = line.x1
    }
    if (line.x2 > xMax) {
      xMax = line.x2
    }
    if (line.y1 > yMax) {
      yMax = line.y1
    }
    if (line.y2 > yMax) {
      yMax = line.y2
    }
  }
  
  return (xMax + 1, yMax + 1)
}

func solvePart1(ventLines: [VentLine]) -> Int {
  let (width, height) = findOceanFloorSize(ventLines: ventLines)
  let lines = ventLines.filter { $0.isStraight() }
  var oceanFloor = Array(repeating: Array(repeating: 0, count: height), count: width);
  for line in lines {
    for (x, y) in line.points() {
      oceanFloor[x][y] += 1
    }
  }
  var totalDangerZones = 0
  for row in oceanFloor {
    for space in row {
      if space > 1 {
        totalDangerZones += 1
      }
      
    }
  }
  return totalDangerZones
}

func solvePart2(ventLines: [VentLine]) -> Int {
  let (width, height) = findOceanFloorSize(ventLines: ventLines)
  var oceanFloor = Array(repeating: Array(repeating: 0, count: height), count: width);
  for line in ventLines {
    for (x, y) in line.points() {
      oceanFloor[x][y] += 1
    }
  }
  var totalDangerZones = 0
  for row in oceanFloor {
    for space in row {
      if space > 1 {
        totalDangerZones += 1
      }

    }
  }
  return totalDangerZones
}


let exampleVentLines = loadLinesFromFile(fileName: "example")
solvePart1(ventLines: exampleVentLines)

let puzzelIntputVentLines = loadLinesFromFile(fileName: "puzzle_input")
solvePart1(ventLines: puzzelIntputVentLines)

solvePart2(ventLines: exampleVentLines)
solvePart2(ventLines: puzzelIntputVentLines)
