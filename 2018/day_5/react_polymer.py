#! /usr/bin/env python3

import fileinput

from collections import deque


def can_react(first, second):
    if (first.isupper() and second.islower()) or (first.islower() and second.isupper()):
        return first.lower() == second.lower()
    return False


def react(polymer):
    buffer = deque()
    new_polymer = deque()
    current = ''
    previous = ''
    has_reaction = False
    for p in polymer:
        if has_reaction:
            new_polymer.append(p)
            continue
        current = p
        if can_react(previous, current):
            current = ''
            new_polymer.pop()
            has_reaction = True
        else:
            previous = current
            new_polymer.append(p)

    return ''.join(new_polymer)


# polymer = 'dabAcCaCBAcCcaDA'
# while True:
#     print(polymer)
#     previous_polymer = polymer
#     polymer = react(polymer)
#     if len(previous_polymer) == len(polymer):
#         print(len(previous_polymer))
#         break

for line in fileinput.input():
    polymer = line.strip()
    # print(polymer)
    while True:
        # print(polymer)
        previous_polymer = polymer
        polymer = react(polymer)
        if len(previous_polymer) == len(polymer):
            print(len(previous_polymer))
            break
