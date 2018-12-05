#! /usr/bin/env python3

import fileinput

from collections import deque


def can_react(first, second):
    if (first.isupper() and second.islower()) or (first.islower() and second.isupper()):
        return first.lower() == second.lower()
    return False


def react(polymer):
    current = ''
    previous = ''
    for i, p in enumerate(polymer):
        current = p
        if can_react(previous, current):
            return polymer[:i - 1] + polymer[i+1:]
        previous = current
    return polymer


for line in fileinput.input():
    polymer = line.strip()
    while True:
        previous_polymer = polymer
        polymer = react(polymer)
        if len(previous_polymer) == len(polymer):
            print(len(previous_polymer))
            break
