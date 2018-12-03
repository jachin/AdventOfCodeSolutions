#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 13 part 2
"""
import fileinput
import copy


def one_picosecond(layers):
    print(layers)
    for layer in layers:
        if 'p' in layer:
            if layer['up']:
                if layer['p'] == 0:
                    layer['p'] += 1
                    layer['up'] = False
                else:
                    layer['p'] -= 1
            else:
                if layer['p'] >= layer['d'] - 1:
                    layer['p'] -= 1
                    layer['up'] = True
                else:
                    layer['p'] += 1

    return layers


def calculate_severity(delay, layers):

    # print("delay: ", delay)
    severity = 0

    # print(layers)

    # print("delay:", len(range(delay)))

    for my_layer in range(len(layers)):

        #print("I'm at layer: ", my_layer)

        # print(layers)

        if 'p' in layers[my_layer]:

            #print("The scanner is at depth: ", layers[my_layer]['p'])

            if layers[my_layer]['p'] == 0:
                # print("Caught at: ", my_layer)
                # print("It has a depth of : ", layers[my_layer]['d'])

                severity += my_layer * layers[my_layer]['d']
                #print("severity", severity)

        layers = one_picosecond(layers)

    return severity


master_layers = []

i = 0

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    (layer_index, depth) = map(int, line.split(': '))
    while i < layer_index:
        master_layers.append({'d': 0, 'i': i})
        i += 1

    master_layers.append({'d': depth, 'i': i, 'p': 0, 'up': False})
    i += 1

# print(layers)

delay = 0

while True:

    layers = copy.deepcopy(master_layers)

    severity = calculate_severity(i, layers)

    print("severity:", severity)
    print("delay:", delay)

    if severity == 0:
        break

    delay += 1
    master_layers = one_picosecond(master_layers)

print(delay)
