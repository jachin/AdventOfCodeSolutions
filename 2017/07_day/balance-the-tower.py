#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 7 part 2
"""

import fileinput


class Disc:

    def __init__(self, name, weight):
        self.name = name
        self.weight = weight
        self.total_weight = weight
        self.children = []
        self.children_str = []
        self.parent = None

    def __str__(self):

        if self.parent:
            parent_name = self.parent.name
        else:
            parent_name = 'None'

        return "name: {}, weight: {}, children: {} parent: {}".format(
            self.name,
            self.weight,
            self.children_str,
            parent_name
        )


programs = {}

for line in fileinput.input():

    line = line.strip()

    if len(line) < 1:
        continue

    parts = line.split()
    name = parts[0]
    weight = parts[1][1:-1]
    children = parts[3:]

    programs[name] = Disc(name=name, weight=int(weight))
    for child in children:
        programs[name].children_str.append(child.strip(','))


for key, program in programs.items():
    for child_str in program.children_str:

        child = programs[child_str]

        programs[key].children.append(child)
        programs[child_str].parent = programs[key]


root = None

for key, program in programs.items():
    if program.parent is None:
        root = program
        break


def calc_weights(program):
    for child_str in program.children_str:
        program.total_weight += calc_weights(programs[child_str])
    return program.total_weight

calc_weights(root)


def find_off_balance_program(program):

    print(program)

    child_weights = []

    if len(program.children) is 0:
        return

    for child in program.children:
        print("child: {} total weight: {} weigh: {}".format(child.name, child.total_weight, child.weight))

    if len(program.children) is 1:
        find_off_balance_program(program.children[0])

    for child in program.children:
        child_weights.append(child.total_weight)
    bad_weight = None
    for w in child_weights:
        if child_weights.count(w) == 1:
            bad_weight = w

    for child in program.children:
        if child.total_weight == bad_weight:
            find_off_balance_program(child)

find_off_balance_program(root)
