#! /usr/bin/env python3

import fileinput
from collections import deque

total_metadata = 0


def build_node(tokens):
    global total_metadata
    number_of_child_nodes = tokens.popleft()
    number_of_metadata_entries = tokens.popleft()

    for i in range(number_of_child_nodes):
        tokens = build_node(tokens)
    for j in range(number_of_metadata_entries):
        total_metadata += tokens.popleft()
    return tokens


def main():
    for line in fileinput.input():
        tokens = deque(map(int, line.split(' ')))
        build_node(tokens)
        print(total_metadata)


if __name__ == '__main__':
    main()
