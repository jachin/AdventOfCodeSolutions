import Cocoa

func loadBinaryDataFromFile(fileName: String) -> [[Int]] {
  let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt")!
  let fileContents = try! String(contentsOf: fileUrl)
  let lines = fileContents.split(separator: "\n")
  var result: [[Int]] = []
  for line in lines {
    var r: [Int] = []
    for c in line {
      let n = Int(String(c))!
      r.append(n)
    }
    result.append(r)
  }
  return result
  
}

func transpose(matrix: [[Int]]) -> [[Int]] {
  let columns = matrix.count
  let rows = matrix.reduce(0) { max($0, $1.count) }
  var result:  [[Int]] = []

  for row in 0 ..< rows {
    result.append([Int]())
    for col in 0 ..< columns {
      result[row].append(matrix[col][row])
    }
  }
  return result
}

func calculatePowerConsuption(data: [[Int]]) -> Int {

  let tData = transpose(matrix: data)
  var gammaRate = ""
  var epsilonRate = ""
  
  for column in tData {
    var indicator = 0
    for field in column {
      if field == 0 {
        indicator += 1
      } else {
        indicator -= 1
      }
    }
    if (indicator > 0) {
      gammaRate += "1"
      epsilonRate += "0"
    } else {
      gammaRate += "0"
      epsilonRate += "1"
    }
  }
  
  return Int(gammaRate, radix: 2)! * Int(epsilonRate, radix: 2)!
}

let exampleInstructions = loadBinaryDataFromFile(fileName: "example")
print(calculatePowerConsuption(data: exampleInstructions))

let part1Data = loadBinaryDataFromFile(fileName: "puzzle_input")
print(calculatePowerConsuption(data: part1Data))
