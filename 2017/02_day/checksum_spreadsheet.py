#! /usr/bin/env python3

import fileinput

sum = 0

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    row = line.split()

    high = None
    low = None

    for num in row:

        number = int(num)

        if high is None:
            high = number

        if low is None:
            low = number

        if number > high:
            high = number

        if number < low:
            low = number

    sum += high - low

print(sum)
