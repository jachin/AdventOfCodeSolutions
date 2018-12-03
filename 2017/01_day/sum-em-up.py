#! /usr/bin/env python3

import fileinput

for line in fileinput.input():

    line = line.strip()

    last_index = len(line)

    if len(line) < 1:
        continue

    print()

    sum = 0
    for i, n in enumerate(line):

        next_index = (i+1) % last_index

        print(i, n, next_index)

        next = line[next_index]
        if next == n:
            sum += int(n)

    print(sum)
