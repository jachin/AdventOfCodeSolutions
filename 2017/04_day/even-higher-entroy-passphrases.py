#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 4 part 2
"""

import fileinput

number_of_valid_passphrases = 0
number_of_invalid_passphrases = 0

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    word_count = {}
    is_passphrase_valid = True
    for word in line.split():

        sorted_word_list = list(word)
        sorted_word_list.sort()
        sorted_word = ''.join(sorted_word_list)

        if sorted_word in word_count:
            is_passphrase_valid = False
            break
        else:
            word_count[sorted_word] = True
    if is_passphrase_valid:
        number_of_valid_passphrases += 1
    else:
        number_of_invalid_passphrases += 1
        print(line)

print(number_of_valid_passphrases)
print(number_of_invalid_passphrases)
