#! /usr/bin/env python3

import fileinput

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    last_index = len(line)
    half_length = int(last_index / 2)

    print(last_index, half_length)

    sum = 0
    for i, n in enumerate(line):

        half_index = (i + half_length) % last_index

        print(i, n, half_index)

        half = line[half_index]
        if half == n:
            sum += int(n)

    print(sum)
