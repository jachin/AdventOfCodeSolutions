import Cocoa

func loadStateFromFile(fileName: String) -> [Int] {
  let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt")!
  let fileContents = try! String(contentsOf: fileUrl)
  let maybeNumbers = fileContents
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .split(separator: ",").map { Int($0) }
  return maybeNumbers.compactMap { $0 }
}

func solvePart1(days: Int, initialState: [Int]) -> Int {
  func aDay(state: [Int]) -> [Int] {
    var newState : [Int] = state
    var newFish : Int = 0
    for (i, fish) in state.enumerated() {
      if (fish == 0) {
        newState[i] = 6
        newFish += 1
      } else {
        newState[i] = fish - 1
      }
    }
    return newState + Array(repeating: 8, count: newFish)
  }
  
  var state = initialState
  
  for _ in 1...days {
    state = aDay(state: state)
  }
  
  return state.count
}

func solvePart2(days: Int, initialState: [Int]) -> Int {
  var state = initialState
  
  for _ in 1...days {
    var newFish : Int = 0
    for (i, fish) in state.enumerated() {
      if (fish == 0) {
        state[i] = 6
        newFish += 1
      } else {
        state[i] = fish - 1
      }
    }
    state.append(contentsOf: Array(repeating: 8, count: newFish))
  }
  
  return state.count
}

let exampleData = loadStateFromFile(fileName: "example")
//solvePart1(days: 18, initialState: exampleData)
//solvePart1(days: 80, initialState: exampleData)

let puzzleData = loadStateFromFile(fileName: "puzzle_input")
//solvePart1(days: 80, initialState: puzzleData)
//solvePart2(days: 256, initialState: exampleData)
print(solvePart2(days: 256, initialState: puzzleData))

