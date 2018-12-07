#! /usr/bin/env python3

import fileinput
import random
import string


class Destination:
    def __init__(self, x, y, is_infinite=False):
        self.x = x
        self.y = y
        self.is_infinite = is_infinite
        self.area = 0
        self.region = set()
        self.letter = random.choice(list(string.ascii_letters))

    def __lt__(self, other):
        return len(self.region) < len(other.region)


def calc_distance(x1, y1, x2, y2):
    return abs(x1 - x2) + abs(y1 - y2)


def calc_centrality(width, height, destinations):
    area = []
    for x in range(width):
        for y in range(height):
            total_distance = 0
            for d in destinations:
                total_distance += calc_distance(x, y, d.x, d.y)
            area.append((total_distance, (x, y)))
    return area


def main():
    destinations = []
    max_x = 0
    max_y = 0
    for line in fileinput.input():
        pieces = line.split(', ')
        x = int(pieces[0])
        y = int(pieces[1])
        destinations.append(Destination(x, y))
        if x > max_x:
            max_x = x
        if y > max_y:
            max_y = y
    area = calc_centrality(max_x, max_y, destinations)
    central_points = list(filter(lambda x: x[0] < 10000, area))
    print(len(central_points))


if __name__ == '__main__':
    main()
