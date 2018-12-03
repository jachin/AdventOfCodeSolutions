#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 12 part 1 and 2
"""

import fileinput

programs = {}

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    (left, right) = line.split(' <-> ')

    left_number = int(left)
    right_numbers = list(map(int, right.split(', ')))

    #print(left_number)
    #print(right_numbers)

    programs[left_number] = set(right_numbers)

# print(programs)

for key, value in programs.items():
    for number in value.copy():
        programs[number] |= programs[key]

# print(programs)

print(len(programs[0]))

set_of_programs = set()

for key, value in programs.items():

    connections = list(value)
    connections.sort()
    set_of_programs.add(tuple(connections))

print(len(set_of_programs))
