#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 11 part 1
"""


class HexGrid():
    location = (0, 0)

    def move_n(self):
        self.locaction = (self.location[0], self.location[1] + 2)

    def move_s(self):
        self.locaction = (self.location[0], self.location[1] - 2)

    def move_nw(self):
        self.locaction = (self.location[0] - 1, self.location[1] + 1)

    def move_sw(self):
        self.locaction = (self.location[0] - 1, self.location[1] - 1)

    def move_ne(self):
        self.locaction = (self.location[0] + 1, self.location[1] + 1)

    def move_se(self):
        self.locaction = (self.location[0] + 1, self.location[1] - 1)
