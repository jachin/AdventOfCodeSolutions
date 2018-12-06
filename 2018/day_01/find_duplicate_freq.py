#! /usr/bin/env python3

import fileinput

changes = []
freqs = {}

for line in fileinput.input():

    line = line.strip()

    changes.append(int(line))

i = 0
freq = 0
while True:

    freq += changes[i % len(changes)]

    if freq in freqs:
        print(freq)
        break
    else:
        freqs[freq] = True

    i += 1
