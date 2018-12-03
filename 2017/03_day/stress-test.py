#! /usr/bin/env python3

"""
Advent of Code 2017.

Day 3 part 2
"""

target_value = 312051

memory_coords = []
memory_coords.append(((0, 0), 1))


def find_value(loc):
    x, y = loc

    def find(x, y):
        for loc in memory_coords:
            if loc[0][0] == x and loc[0][1] == y:
                return loc[1]
        return 0

    value = 0
    value += find(x - 1, y - 1)
    value += find(x, y - 1)
    value += find(x + 1, y - 1)
    value += find(x + 1, y)
    value += find(x + 1, y + 1)
    value += find(x, y + 1)
    value += find(x - 1, y + 1)
    value += find(x - 1, y)

    return value


def move(loc, direction):
    loc_coords, value = loc

    x1, y1 = loc_coords
    x2, y2 = direction
    new_loc = (x1 + x2, y1 + y2)

    new_value = find_value(new_loc)

    return (new_loc, new_value)


# move right
m2 = move(memory_coords[-1], (1, 0))
memory_coords.append(m2)

# move up
m3 = move(memory_coords[-1], (0, -1))
memory_coords.append(m3)

i = 3
length = 2

directions = [(-1, 0), (0, 1), (1, 0), (0, -1)]
di = 0


while True:

    direction = directions[di % 4]
    for i1 in range(length):
        i += 1
        memory_coords.append(move(memory_coords[-1], direction))

        if memory_coords[-1][1] > target_value:
            break

    if memory_coords[-1][1] > target_value:
        break

    di += 1

    direction = directions[di % 4]

    for i2 in range(length):
        i += 1
        memory_coords.append(move(memory_coords[-1], direction))

        if memory_coords[-1][1] > target_value:
            break

    if memory_coords[-1][1] > target_value:
        break

    di += 1

    length += 1

memory_location = memory_coords[-1]

print(memory_location)

coords, value = memory_location

print(value)
