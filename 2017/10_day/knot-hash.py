#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 10 part 1
"""

import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("size", type=int)
args = parser.parse_args()


def update_list(a_list, update_list, start_index):
    for i, update_item in enumerate(update_list):
        update_index = (i + start_index) % len(a_list)
        a_list[update_index] = update_item
    return a_list


def get_slice(a_list, length, start_index):
    slice = []
    for i in range(length):
        index = (i + start_index) % len(a_list)

        slice.append(a_list[index])
    return slice


def print_workspace(workspace, start, end):
    output = ""
    for i, num in enumerate(workspace):
        if i == start:
            output += "("
        output += str(num)
        if i == end - 1:
            output += ")"
        if i < len(workspace) - 1:
            output += " "
    print(output)


for line in sys.stdin:

    line = line.strip()

    if len(line) < 1:
        continue

    lengths = list(map(int, line.split(',')))

    workspace = list(range(args.size))

    start_of_list = 0
    skip_size = 0
    pos = 0

    for l in lengths:

        start_of_selection_i = pos % args.size
        end_of_selection_i = (pos + l) % args.size

        print(l, start_of_selection_i, end_of_selection_i)
        print_workspace(workspace, start_of_selection_i, end_of_selection_i)

        selection = get_slice(workspace, l, pos)

        print(selection)
        selection.reverse()
        print(selection)

        update_list(workspace, selection, start_of_selection_i)

        pos += skip_size + l

        skip_size += 1

        print('pos', pos)

        # print(wordspace)

    print(workspace)
    print(workspace[0] * workspace[1])
