
def d = {
    return 72
}

def e = {
    return 507
}

def wires = [
    'd': d,
    'e': e,
    // 'f': { 492 },
    // 'g': { 114 },
    // 'h': { 65412 },
    // 'i': { 65079 },
    // 'x': { 123 },
    // 'y': { 456 },
]

wires.collectEntries({
    println(it.call())
})

/*
new File('input.txt').eachLine { line ->

    if (line.split().size() == 3) {
        def (input, arrow, output) = line.split()

        if (input.isNumber()) {
            wires[output] = {
                return input
            }
        }
        else {
            wires[output] = {
                return wires[input]
            }
        }
    }
    else if (line.split().size() == 4) {

        def (command, input, arrow, output) = line.split()

        if (command == 'NOT') {
            wires[output] = {
                return ~ input
            }
        }
    }
    else if (line.split().size() == 5) {

        def (inputR, command, inputL, arrow, output) = line.split()

        if (command == 'AND') {
            wires[output] = {
                return wires[inputR] & wires[inputL]
            }
        }
        else if (command == 'OR') {
            wires[output] = {
                return wires[inputR] | wires[inputL]
            }
        }
        else if (command == 'RSHIFT') {
            wires[output] = {
                return wires[inputR] >> wires[inputL]
            }
        }
        else if (command == 'LSHIFT') {
            wires[output] = {
                return wires[inputR] << wires[inputL]
            }
        }
    }
}

// printnl(wires.d())

//printnl(wires.a)
*/
