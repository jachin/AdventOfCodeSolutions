#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 9 part 1
"""

import fileinput


for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    groups = []
    garbage = 0

    in_garbage = False
    ignore_next_charater = False

    for i, char in enumerate(line):

        if in_garbage:
            if ignore_next_charater:
                ignore_next_charater = False
                continue

            if char == '>':
                in_garbage = False
                continue
            elif char == '!':
                ignore_next_charater = True
                continue

            garbage += 1
            continue

        if char == '{':
            if len(groups) < 1:
                groups.append(1)
            else:
                groups.append(groups[-1] + 1)
        elif char == '}':
            pass
        elif char == '<':
            in_garbage = True

    print(garbage)
