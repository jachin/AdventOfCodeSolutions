import Cocoa

func loadStateFromFile(fileName: String) -> [[Int]] {
    let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt")!
    let fileContents = try! String(contentsOf: fileUrl)
    let lines = fileContents.split(separator: "\n")
    var result: [[Int]] = []
    for line in lines {
        var r: [Int] = []
        for numAsStr in line {
            let n = Int(String(numAsStr))!
            r.append(n)
        }
        result.append(r)
    }
    return result
}

func getNeighbors(seaFloor: [[Int]], position: (Int, Int)) -> [Int] {
    let (x, y) = position
    let top = (x, y+1)
    let right = (x + 1, y)
    let bottom = (y - 1, x)
    let left = (y, x - 1)
}

func part1(seaFloor: [[Int]]) -> Int {
    
    return 0
}

loadStateFromFile(fileName: "example")
