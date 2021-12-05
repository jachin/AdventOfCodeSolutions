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

func binaryArrayToInt(array: [Int]) -> Int {
    var s = ""
    for i in array {
        s += String(i)
    }
    return Int(s, radix: 2)!
}

func calculateOxygenGeneratorRating(data: [[Int]], colIndex: Int) -> Int {
    if (data.count == 1) {
        return binaryArrayToInt(array: data[0])
    }
    let tData = transpose(matrix: data)
    let column = tData[colIndex]
    var zeros = 0
    var ones = 0
    
    for field in column {
        if field == 0 {
            zeros += 1
        } else {
            ones += 1
        }
    }
    if zeros > ones {
        let filteredData = data.filter { $0[colIndex] == 0 }
        return calculateOxygenGeneratorRating(data: filteredData, colIndex: colIndex + 1)
    }
    else {
        let filteredData = data.filter { $0[colIndex] == 1 }
        return calculateOxygenGeneratorRating(data: filteredData, colIndex: colIndex + 1)
    }
}

func calculateCO2ScrubberRating(data: [[Int]], colIndex: Int) -> Int {
    if (data.count == 1) {
        return binaryArrayToInt(array: data[0])
    }
    let tData = transpose(matrix: data)
    let column = tData[colIndex]
    var zeros = 0
    var ones = 0
    
    for field in column {
        if field == 0 {
            zeros += 1
        } else {
            ones += 1
        }
    }
    if ones >= zeros  {
        let filteredData = data.filter { $0[colIndex] == 0 }
        return calculateCO2ScrubberRating(data: filteredData, colIndex: colIndex + 1)
    }
    else {
        let filteredData = data.filter { $0[colIndex] == 1 }
        return calculateCO2ScrubberRating(data: filteredData, colIndex: colIndex + 1)
    }
}

func calculateLifeSupportRating(data: [[Int]]) -> Int {
    let ox = calculateOxygenGeneratorRating(data: data, colIndex: 0)
    let co = calculateCO2ScrubberRating(data: data, colIndex: 0)
    return ox * co
}


let exampleInstructions = loadBinaryDataFromFile(fileName: "example")
print(calculatePowerConsuption(data: exampleInstructions))

let puzzelInput = loadBinaryDataFromFile(fileName: "puzzle_input")
print(calculatePowerConsuption(data: puzzelInput))

print(calculateLifeSupportRating(data: exampleInstructions))
print(calculateLifeSupportRating(data: puzzelInput))
