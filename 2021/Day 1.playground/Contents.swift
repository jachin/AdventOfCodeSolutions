import Cocoa
import Foundation

func calculateDepthMeasurementIncreases(depths: [Int]) -> Int {
  var currentDepth = depths[0]
  var numberOfDepthChanges = 0
  for depth in depths {
    if (isDeeper(currentDepth: currentDepth, depth: depth)) {
      numberOfDepthChanges += 1
    }
    currentDepth = depth;
  }
  return numberOfDepthChanges
}

func day2(depths: [Int]) -> Int {
  var windows = [[Int]]()
  for (index, _) in depths.enumerated() {
    let window = depths.suffix(from: index).prefix(3)
    if window.count == 3 {
      windows.append(Array(window))
    }
  }
  
  let windowDepths = windows.map { $0[0] + $0[1] + $0[2] }
  
  return calculateDepthMeasurementIncreases(depths: windowDepths)
}

func isDeeper(currentDepth: Int, depth: Int) -> Bool {
  return depth > currentDepth
}

func loadNumbersFromFile(fileName: String) -> [Int] {
  if let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt") {
    if let fileContents = try? String(contentsOf: fileUrl) {
      let numbersAsStrings = fileContents.split(separator: "\n")
      return numbersAsStrings.map { Int($0)! }
    }
  }
  return []
}

// Day 1 example

let day1ExampleNumbers = loadNumbersFromFile(fileName: "example")
print( calculateDepthMeasurementIncreases(depths: day1ExampleNumbers) )


// Day 1
let day1Numbers = loadNumbersFromFile(fileName: "day1")


print( calculateDepthMeasurementIncreases(depths: day1Numbers) )

// Day 2
print(day2(depths: day1Numbers))
