#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 13 part 1
"""

import fileinput

layers = []

i = 0


def one_picosecond(layers):
    for layer in layers:
        if 'p' in layer:
            if layer['up']:
                if layer['p'] == 0:
                    layer['p'] += 1
                    layer['up'] = False
                else:
                    layer['p'] -= 1
            else:
                if layer['p'] == layer['d'] - 1:
                    layer['p'] -= 1
                    layer['up'] = True
                else:
                    layer['p'] += 1

    return layers


for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    (layer_index, depth) = map(int, line.split(': '))
    while i < layer_index:
        layers.append({'d': 0, 'i': i})
        i += 1

    layers.append({'d': depth, 'i': i, 'p': 0, 'up': False})
    i += 1

print(layers)

severity = 0
for my_layer in range(len(layers)):

    #print("I'm at layer: ", my_layer)

    if 'p' in layers[my_layer]:

        #print("The scanner is at depth: ", layers[my_layer]['p'])

        if layers[my_layer]['p'] == 0:
            print("Caught at: ", my_layer)
            #print("It has a depth of : ", layers[my_layer]['d'])

            severity += my_layer * layers[my_layer]['d']
            #print("severity", severity)

    layers = one_picosecond(layers)
    # print(layers)

print("severity", severity)
