#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 5 part 1
"""

import fileinput

instructions = []

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    number = int(line)

    instructions.append(number)

i = 0
n = 0

while True:

    n += 1
    j = i
    i += instructions[i]

    print(n, i)

    if i < 0 or i >= len(instructions):
        break

    if instructions[j] > 2:
        instructions[j] -= 1
    else:
        instructions[j] += 1
