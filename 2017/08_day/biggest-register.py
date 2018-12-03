#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 8 part 1
"""

import fileinput

registers = {}

for line in fileinput.input():

    print(registers)

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

    print(registers)

    print('register value: ', registers[condition_register])
    print('condition: ', condition)
    print('condition_value: ', condition_value)

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

        print('register value before:', registers[register])

        if command == 'inc':
            registers[register] += amount
        elif command == 'dec':
            registers[register] -= amount

        print('register value after:', registers[register])

    print('\n')

print(registers)

biggest_key = max(registers, key=registers.get)
print(biggest_key)
print(registers[biggest_key])
