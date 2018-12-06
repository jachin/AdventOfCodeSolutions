#! /usr/bin/env python3

import fileinput
import string
from functools import lru_cache

from collections import deque

@lru_cache(maxsize=1024)
def can_react(first, second):
    if first.isupper():
        if second.islower():
            return first.lower() == second
    else:
        if second.isupper():
            return first.upper() == second
    return False


def react(polymer, start=0):
    current = ''
    previous = ''
    for i in range(start, len(polymer)):
        current = polymer[i]
        if can_react(previous, current):
            (head, pattern, tail) = polymer.partition(previous + current)
            return (i - 2, '{}{}'.format(head, tail))
        previous = current
    return (i - 2, polymer)


def collapse(polymer):
    i = 0
    while True:
        previous_polymer = polymer
        (i, polymer) = react(polymer, i)
        if i < 0:
            i = 0
        if len(previous_polymer) == len(polymer):
            return polymer


def strip_type(t, polymer):
    polymer = polymer.replace(t.upper(), '')
    polymer = polymer.replace(t.lower(), '')
    return polymer


results = {}

for line in fileinput.input():
    polymer = line.strip()
    for letter in string.ascii_lowercase:
        reduced_polymer = strip_type(letter, polymer)
        collaposed_polymer = collapse(reduced_polymer)
        results[letter] = len(collaposed_polymer)

best_letter = min(results, key=results.get)
print('{}: {}'.format(best_letter, results[best_letter]))
