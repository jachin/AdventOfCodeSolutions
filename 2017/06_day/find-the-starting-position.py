#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 6 part 2
"""

import fileinput


def find_max_index(registers):
    max = 0
    max_i = 0

    for i, n in enumerate(registers):
        if n > max:
            max = n
            max_i = i

    return max_i


def balance_memory(registers):
    max_i = find_max_index(registers)
    number_of_blocks = registers[max_i]

    registers[max_i] = 0
    i = 1
    while number_of_blocks > 0:

        index = (max_i + i) % len(registers)

        registers[index] += 1
        number_of_blocks -= 1
        i += 1
    return registers


def find_the_loop(starting_registers):
    i = 0

    registers = starting_registers[:]

    balancing_results = {}

    while True:
        i += 1
        result = balance_memory(registers)

        result_key = " ".join(list(map(str, result)))

        # print(result_key)

        if result_key in balancing_results:
            break

        balancing_results[result_key] = i

    return i - balancing_results[result_key]


for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    starting_registers = list(map(int, line.split()))

    print(find_the_loop(starting_registers))
