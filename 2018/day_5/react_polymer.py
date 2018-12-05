#! /usr/bin/env python3

import fileinput
import cProfile
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


def react(polymer):
    current = ''
    previous = ''
    for p in polymer:
        current = p
        if can_react(previous, current):
            (head, pattern, tail) = polymer.partition(previous + current)
            return '{}{}'.format(head, tail)
        previous = current
    return polymer


def main():
    for line in fileinput.input():
        polymer = line.strip()
        while True:
            previous_polymer = polymer
            polymer = react(polymer)
            if len(previous_polymer) == len(polymer):
                print(len(previous_polymer))
                break


if __name__ == '__main__':
    #cProfile.run('main()')
    main()
