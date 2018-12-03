#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 8 part 2
"""

import fileinput

registers = {}

highest_value = 0

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    parts = line.split()
    register = parts[0]
    command = parts[1]
    amount = int(parts[2])

    condition_register = parts[4]
    condition = parts[5]
    condition_value = int(parts[6])

    registers.setdefault(register, 0)
    registers.setdefault(condition_register, 0)

    if condition == '>':
        do_it = registers[condition_register] > condition_value
    elif condition == '<':
        do_it = registers[condition_register] < condition_value
    elif condition == '>=':
        do_it = registers[condition_register] >= condition_value
    elif condition == '<=':
        do_it = registers[condition_register] <= condition_value
    elif condition == '!=':
        do_it = registers[condition_register] != condition_value
    elif condition == '==':
        do_it = registers[condition_register] == condition_value
    else:
        raise ValueError("Unknown condition: {}".format(condition))

    if do_it:

        if command == 'inc':
            registers[register] += amount
        elif command == 'dec':
            registers[register] -= amount

    biggest_key = max(registers, key=registers.get)
    if registers[biggest_key] > highest_value:
        highest_value = registers[biggest_key]

print(highest_value)
