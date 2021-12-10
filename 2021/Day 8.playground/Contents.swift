import Cocoa

struct Segment {
    var a: Bool = false
    var b: Bool = false
    var c: Bool = false
    var d: Bool = false
    var e: Bool = false
    var f: Bool = false
    var g: Bool = false
}

func segmentToArray(segment: Segment) -> [Bool] {
    return [segment.a, segment.b, segment.c, segment.d, segment.e, segment.f, segment.g]
}

func is1digit(segment: Segment) -> Bool {
    (segmentToArray(segment: segment).filter { $0 } ).count == 2
}

func is4digit(segment: Segment) -> Bool {
    (segmentToArray(segment: segment).filter { $0 } ).count == 4
}

func is7digit(segment: Segment) -> Bool {
    (segmentToArray(segment: segment).filter { $0 } ).count == 3
}

func is8digit(segment: Segment) -> Bool {
    (segmentToArray(segment: segment).filter { $0 } ).count == 7
}

func isEasyDigit(segment: Segment) -> Bool {
    return is1digit(segment: segment) || is4digit(segment: segment) || is7digit(segment: segment) || is8digit(segment: segment)
}


struct Entry {
    var signalPatterns: [Segment] = []
    var outputValues: [Segment] = []
}

func stringToSegment(str: String) -> Segment {
    var segment = Segment()
    for c in str {
        switch c {
        case "a":
            segment.a = true
        case "b":
            segment.b = true
        case "c":
            segment.c = true
        case "d":
            segment.d = true
        case "e":
            segment.e = true
        case "f":
            segment.f = true
        case "g":
            segment.g = true
        default:
            break
            
        }
    }
    return segment
}

func loadStateFromFile(fileName: String) -> [Entry] {
    let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "txt")!
    let fileContents = try! String(contentsOf: fileUrl)
    let lines = fileContents.split(separator: "\n")
    var pairs: [(String, String)] = []
    for line in lines {
        let parts = line.split(separator: "|")
        pairs.append((String(parts[0]), String(parts[1])))
    }
    
    return pairs.map { (pair) -> Entry in
        let signalPatterns = pair.0.split(separator: " ").map { stringToSegment(str: String($0)) }
        let outputValues = pair.1.split(separator: " ").map { stringToSegment(str: String($0)) }
        return Entry(signalPatterns: signalPatterns, outputValues: outputValues)
    }
}

func part1(entries: [Entry]) -> Int {
    entries.map { $0.outputValues.filter { isEasyDigit(segment: $0) }.count }.reduce(0, +)
}

part1(entries: loadStateFromFile(fileName: "example"))
part1(entries: loadStateFromFile(fileName: "puzzle_input"))
