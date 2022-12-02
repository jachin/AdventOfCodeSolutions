import Cocoa

struct SegmentDisplay {
    var a: Bool = false
    var b: Bool = false
    var c: Bool = false
    var d: Bool = false
    var e: Bool = false
    var f: Bool = false
    var g: Bool = false
}

struct WireMapping {
    var top: String? = nil
    var topLeft : String? = nil
    var topRight : String? = nil
    var middle : String? = nil
    var bottomLeft : String? = nil
    var bottomRight : String? = nil
    var bottom: String? = nil
}

func segmentToArray(segment: SegmentDisplay) -> [Bool] {
    return [segment.a, segment.b, segment.c, segment.d, segment.e, segment.f, segment.g]
}


func segmentToPairs(segment: SegmentDisplay) -> [(String, Bool)] {
    return [("a", segment.a),("b", segment.b), ("c", segment.c), ("d", segment.d), ("e", segment.e), ("f", segment.f), ("g", segment.g)]
}


func segmentToSet(segment: SegmentDisplay) -> Set<String> {
    let arr = segmentToPairs(segment: segment).filter { (_, b) in b }.map { (c, _) in c }
    var set: Set<String> = Set<String>()
    for a in arr {
        set.insert(a)
    }
    return set
}

func numberOfLitSegments(segment: SegmentDisplay) -> Int {
    segmentToArray(segment: segment).filter { $0 }.count
}

func is1digit(segment: SegmentDisplay) -> Bool {
    (segmentToArray(segment: segment).filter { $0 } ).count == 2
}

func find1Digit(segments: [SegmentDisplay]) -> SegmentDisplay? {
    segments.filter { is1digit(segment: $0) }.first
}

func is4digit(segment: SegmentDisplay) -> Bool {
    (segmentToArray(segment: segment).filter { $0 } ).count == 4
}

func find4Digit(segments: [SegmentDisplay]) -> SegmentDisplay? {
    segments.filter { is4digit(segment: $0) }.first
}

func is7digit(segment: SegmentDisplay) -> Bool {
    (segmentToArray(segment: segment).filter { $0 } ).count == 3
}

func find7Digit(segments: [SegmentDisplay]) -> SegmentDisplay? {
    segments.filter { is7digit(segment: $0) }.first
}

func is8digit(segment: SegmentDisplay) -> Bool {
    (segmentToArray(segment: segment).filter { $0 } ).count == 7
}

func find8Digit(segments: [SegmentDisplay]) -> SegmentDisplay? {
    segments.filter { is8digit(segment: $0) }.first
}

func isEasyDigit(segment: SegmentDisplay) -> Bool {
    return is1digit(segment: segment) || is4digit(segment: segment) || is7digit(segment: segment) || is8digit(segment: segment)
}

func findTopWire(segments: [SegmentDisplay]) -> String? {
    let maybeA1Digit: SegmentDisplay? = find1Digit(segments: segments)
    let maybeA7Digit: SegmentDisplay? = find7Digit(segments: segments)
    
    if let a1Digit = maybeA1Digit, let a7Digit = maybeA7Digit {
        return segmentToSet(segment: a7Digit).subtracting(segmentToSet(segment: a1Digit)).first
    }
    return nil
}

func findTopRightWire(segments: [SegmentDisplay]) -> String? {
    let maybeA1Digit : SegmentDisplay? = find1Digit(segments: segments)
    let maybeA8Digit : SegmentDisplay? = find8Digit(segments: segments)
    
    for s in segments {
        if (numberOfLitSegments(segment: s) == 6) {
            if let a1Digit = maybeA1Digit, let a8Digit = maybeA8Digit {
                let a1DigitSet = segmentToSet(segment: a1Digit)
                let a8DigitSet = segmentToSet(segment: a8Digit)
                let displaySet = segmentToSet(segment: s)
                
                let result = a8DigitSet.subtracting(displaySet).union(a1DigitSet)
                
                if (result.count == 2) {
                    return a8DigitSet.subtracting(displaySet).first
                }
                
            }
        }
    }
    return nil
}

func findBottomRightWire(segments: [SegmentDisplay], topWire: String, topRightWire: String) -> String? {
    let knownWires: Set<String> = [topWire, topRightWire]
    let maybe7Digit : SegmentDisplay? = find7Digit(segments: segments)
    if let a7Digit = maybe7Digit {
        return segmentToSet(segment: a7Digit).subtracting(knownWires).first
    }
    return nil
}

func findBottomLeftWire(segments: [SegmentDisplay]) -> String? {
    let maybeA8Digit : SegmentDisplay? = find8Digit(segments: segments)
    let maybeA4Digit : SegmentDisplay? = find4Digit(segments: segments)
    
    for s in segments {
        if (numberOfLitSegments(segment: s) == 6) {
            if let a4Digit = maybeA4Digit, let a8Digit = maybeA8Digit {
                let a4DigitSet = segmentToSet(segment: a4Digit)
                let a8DigitSet = segmentToSet(segment: a8Digit)
                let displaySet = segmentToSet(segment: s)
                
                let result = a8DigitSet.subtracting(displaySet).subtracting(a4DigitSet)
                
                if (result.count == 1) {
                    return result.first
                }
                
            }
        }
    }
    return nil
}

func findBottomWire(segments: [SegmentDisplay]) -> String? {
    var fiveSegmentNumbers: Set<String> = []
    for s in segments {
        if (numberOfLitSegments(segment: s) == 5) {
            if fiveSegmentNumbers.isEmpty {
                fiveSegmentNumbers = segmentToSet(segment: s)
            } else {
                fiveSegmentNumbers.intersection(segmentToSet(segment: s))
            }
        }
    }
    
    let maybeA4Digit : SegmentDisplay? = find4Digit(segments: segments)
    let maybe7Digit : SegmentDisplay? = find7Digit(segments: segments)
    
    
    
    if let a4Digit = maybeA4Digit, let a7Digit = maybe7Digit {
        
        let a4DigitSet = segmentToSet(segment: a4Digit)
        let a7DigitSet = segmentToSet(segment: a7Digit)
        
        let result = fiveSegmentNumbers.subtracting(a4DigitSet).subtracting(a7DigitSet)
        
        if (result.count == 1) {
            return result.first
        }
    }
    
    return nil
}


struct Entry {
    var signalPatterns: [SegmentDisplay] = []
    var outputValues: [SegmentDisplay] = []
}

func stringToSegment(str: String) -> SegmentDisplay {
    var segment = SegmentDisplay()
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

func part2(entries: [Entry]) {
    for entry in entries {
        var wireMapping = WireMapping()
        wireMapping.top = findTopWire(segments: entry.signalPatterns)
        wireMapping.topRight = findTopRightWire(segments: entry.signalPatterns)
        wireMapping.bottomRight = findBottomRightWire(segments: entry.signalPatterns, topWire: wireMapping.top!, topRightWire: wireMapping.topRight!)
        wireMapping.bottomLeft = findBottomLeftWire(segments: entry.signalPatterns)
        wireMapping.bottom = findBottomWire(segments: entry.signalPatterns)
        print(wireMapping)
    }
}

//part1(entries: loadStateFromFile(fileName: "example"))
//part1(entries: loadStateFromFile(fileName: "puzzle_input"))

part2(entries: loadStateFromFile(fileName: "example"))
