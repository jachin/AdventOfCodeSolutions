#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 7 part 1
"""

import fileinput


class Disc:

    def __init__(self, name, weight):
        self.name = name
        self.weight = weight
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
        programs[child_str].children.append(programs[child_str])
        programs[child_str].parent = program

for key, program in programs.items():
    if program.parent is None:
        print(program.name)
