import Cocoa

func loadStateFromFile(fileName: String) -> [Int] {
    let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt")!
    let fileContents = try! String(contentsOf: fileUrl)
    let maybeNumbers = fileContents
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: ",").map { Int($0) }
    return maybeNumbers.compactMap { $0 }
}

func part1(initialState: [Int]) -> Int {
    
    let highest = initialState.max(by: <)!
    let lowest = initialState.min(by: <)!
    var best: Int = Int.max
    
    for height in lowest...highest {
        let fuelCost = initialState.map { abs($0 - height) }.reduce(0, +)
        if fuelCost < best {
            best = fuelCost
        }
    }
    
    return best
}

part1(initialState: loadStateFromFile(fileName: "example"))
part1(initialState: loadStateFromFile(fileName: "puzzle_input"))
