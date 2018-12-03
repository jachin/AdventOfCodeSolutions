#! /usr/bin/env python3

import fileinput

current_freq = 0

for line in fileinput.input():

    line = line.strip()

    freq = int(line)
    current_freq += freq

print(current_freq)
