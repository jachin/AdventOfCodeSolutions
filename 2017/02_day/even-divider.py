#! /usr/bin/env python3

import fileinput

sum = 0

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    row = line.split()

    found_it = False

    for num in row:

        if found_it:
            break

        numerator = int(num)

        for den in row:
            denominator = int(den)

            if numerator == denominator:
                continue

            if denominator > numerator:
                continue

            if numerator % denominator == 0:

                sum += numerator / denominator

                print(numerator, denominator, sum)

                found_it = True
                break

print(int(sum))
