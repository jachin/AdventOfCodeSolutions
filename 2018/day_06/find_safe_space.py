#! /usr/bin/env python3

import fileinput
from colorama import init, Fore, Back, Style
import random
import string


class Destination:
    def __init__(self, x, y, is_infinite=False):
        self.x = x
        self.y = y
        self.is_infinite = is_infinite
        self.area = 0
        self.region = set()
        self.letter = random.choice(list(string.ascii_lowercase))

    def __lt__(self, other):
        return len(self.region) < len(other.region)


def calc_distance(x1, y1, x2, y2):
    return abs(x1 - x2) + abs(y1 - y2)


def find_areas(width, height, destinations):
    for x in range(width):
        for y in range(height):
            distances = {}
            for destination in destinations:
                distances[destination] = calc_distance(
                    destination.x,
                    destination.y,
                    x,
                    y
                )
            closest_destination = min(distances, key=distances.get)
            closest_destination.area += 1
            closest_destination.region.add((x, y))
    return destinations


def output_area(width, height, destinations):
    data = {}
    for d in destinations:
        for cords in d.region:
            data[(cords)] = d.letter

    with open('out.txt', 'w') as f:
        for x in range(width):
            line = []
            for y in range(height):
                letter = data[(x, y)]
                line.append(letter)
            print(''.join(line), file=f)
    return data


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
    destinations = find_areas(max_x, max_y, destinations)
    area = output_area(max_x, max_y, destinations)
    edges = set()
    for x in range(max_x):
        for y in (0, max_y):
            edges.add((x, y))
    for x in (0, max_x):
        for y in range(max_y):
            edges.add((x, y))

    for destination in destinations:
        if len(edges.intersection(destination.region)) > 0:
            destination.is_infinite = True
        #     print("{} is infinite".format(destination.letter))
        # else:
        #     print("{} is NOT infinite".format(destination.letter))
        #     print("area: {}".format(destination.area))
        #print(edges.intersection(destination.region))

    canidates = list(filter(lambda x: not x.is_infinite, destinations))

    print(len(destinations))
    print(len(canidates))

    canidates.sort()

    print(canidates[0].area)
    print(canidates[-1].area)
    print(canidates[-1].letter)


if __name__ == '__main__':
    init()
    main()
