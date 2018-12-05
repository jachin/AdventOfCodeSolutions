#! /usr/bin/env python3

import fileinput
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
    # print(start, len(polymer))
    for i in range(start, len(polymer)):
        current = polymer[i]
        if can_react(previous, current):
            (head, pattern, tail) = polymer.partition(previous + current)
            return (i - 2, '{}{}'.format(head, tail))
        previous = current
    return (i - 2, polymer)


def main():
    for line in fileinput.input():
        polymer = line.strip()
        i = 0
        while True:
            previous_polymer = polymer
            (i, polymer) = react(polymer, i)
            if i < 0:
                i = 0
            if len(previous_polymer) == len(polymer):
                print(len(previous_polymer))
                break


if __name__ == '__main__':
    main()
