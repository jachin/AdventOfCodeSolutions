#! /usr/bin/env python3

import fileinput


def count_letters(l):
    counts = {}
    for letter in list(l):
        if letter in counts:
            counts[letter] += 1
        else:
            counts[letter] = 1
    return counts


def calc_line(l):
    r = count_letters(l)
    has_2 = 2 in r.values()
    has_3 = 3 in r.values()
    return (int(has_2), int(has_3))


twos = 0
threes = 0
for line in fileinput.input():

    line = line.strip()
    (m2, m3) = calc_line(line)
    twos += m2
    threes += m3

print(twos * threes)
