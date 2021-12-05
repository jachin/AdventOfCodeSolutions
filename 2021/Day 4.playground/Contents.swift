import Cocoa

func transposeInts(matrix: [[Int]]) -> [[Int]] {
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

func transposeBools(matrix: [[Bool]]) -> [[Bool]] {
    let columns = matrix.count
    let rows = matrix.reduce(0) { max($0, $1.count) }
    var result:  [[Bool]] = []
    
    for row in 0 ..< rows {
        result.append([Bool]())
        for col in 0 ..< columns {
            result[row].append(matrix[col][row])
        }
    }
    return result
}

class BingoCard {
  var card: [[Int]] = []
  var marks: [[Bool]] = []
  
  func setup(numbers: [[Int]]) {
    for (i, row) in numbers.enumerated() {
      card.append([])
      marks.append([])
      for n in row {
        card[i].append(n)
        marks[i].append(false)
      }
    }
  }
  
  func markNumber(num: Int) {
    for (i, row) in card.enumerated() {
      for (j, n) in row.enumerated() {
        if (num == n) {
          marks[i][j] = true
        }
      }
    }
  }
  
  func bingo() -> Bool {
    for row in marks {
      if (row.filter { $0 }.count == 5) {
        return true
      }
    }
    
    let tMarks = transposeBools(matrix: marks)
    for row in tMarks {
      if (row.filter { $0 }.count == 5) {
        return true
      }
    }
    
    return false
  }
  
  func sunUnmarkedNumbers() -> Int {
    var sum = 0
    for (i, row) in marks.enumerated() {
      for (j, mark) in row.enumerated() {
        if (!mark) {
          sum += card[i][j]
        }
      }
    }
    return sum
  }
  
  func bingoNumbers() -> [Int] {
    for (i, row) in marks.enumerated() {
      if (row.filter { $0 }.count == 5) {
        return card[i]
      }
    }
    return []
  }
}

func loadDrawnNumbersFromFile(fileName: String) -> [Int] {
  let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt")!
  let fileContents = try! String(contentsOf: fileUrl)
  let lines = fileContents.split(separator: "\n")
  let firstLine = lines[0]
  return firstLine.split(separator: ",").map { Int($0)! }
}

func loadCardsFromFile(fileName: String) -> [BingoCard] {
  let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt")!
  let fileContents = try! String(contentsOf: fileUrl)
  let sections = fileContents.components(separatedBy: "\n")
  let cardSections = sections[2 ..< sections.endIndex]
  var cards: [BingoCard] = []
  var buffer: [[Int]] = []
  for line in cardSections {
    if line.count == 0 {
      let newCard = BingoCard()
      newCard.setup(numbers: buffer)
      cards.append(newCard)
      buffer = []
    } else {
      buffer.append(line.split(separator: " ").map { $0.trimmingCharacters(in: [" "]) }.map { Int($0)! })
    }
  }
  return cards
}

func solvePart1(drawnNumbers: [Int], cards: [BingoCard]) -> Int {
  for drawnNumber in drawnNumbers {
    for card in cards {
      card.markNumber(num: drawnNumber)
      if (card.bingo()) {
        card.bingoNumbers()
        card.sunUnmarkedNumbers()
        return card.sunUnmarkedNumbers() * drawnNumber
      }
    }
  }
  return -1
}

func solvePart2(drawnNumbers: [Int], cards: [BingoCard]) -> Int {
  var lastWinningCard: BingoCard? = nil
  var lastDrawnNumber = -1
  var notWinners = cards
  for drawnNumber in drawnNumbers {
    for card in notWinners {
      card.markNumber(num: drawnNumber)
      if (card.bingo()) {
        lastWinningCard = card
        lastDrawnNumber = drawnNumber
        
      }
    }
    notWinners = notWinners.filter { !$0.bingo() }
    notWinners.count
  }
  lastWinningCard!.bingoNumbers()
  lastWinningCard!.sunUnmarkedNumbers()
  return lastWinningCard!.sunUnmarkedNumbers() * lastDrawnNumber
}

let exampleDrawnNumbers = loadDrawnNumbersFromFile(fileName: "example")
let exampleCards = loadCardsFromFile(fileName: "example")
solvePart1(drawnNumbers: exampleDrawnNumbers, cards: exampleCards)

let puzzelInputDrawnNumbers = loadDrawnNumbersFromFile(fileName: "puzzle_input")
let puzzleInputCards = loadCardsFromFile(fileName: "puzzle_input")
solvePart1(drawnNumbers: puzzelInputDrawnNumbers, cards: puzzleInputCards)

solvePart2(drawnNumbers: puzzelInputDrawnNumbers, cards: puzzleInputCards)
