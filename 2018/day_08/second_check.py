#! /usr/bin/env python3

import fileinput
from collections import deque


def build_node(tokens):
    number_of_child_nodes = tokens.popleft()
    number_of_metadata_entries = tokens.popleft()

    child_node_values = {}

    for i in range(number_of_child_nodes):
        (child_value, tokens) = build_node(tokens)
        child_node_values[i + 1] = child_value

    value = 0
    metadata = []

    for j in range(number_of_metadata_entries):
        metadata.append(tokens.popleft())

    if number_of_child_nodes < 1:
        value = sum(metadata)
    else:
        for data in metadata:
            if data in child_node_values:
                value += child_node_values[data]

    return (value, tokens)


def main():
    for line in fileinput.input():
        tokens = deque(map(int, line.split(' ')))
        (value, tokens) = build_node(tokens)
        print(value)


if __name__ == '__main__':
    main()
