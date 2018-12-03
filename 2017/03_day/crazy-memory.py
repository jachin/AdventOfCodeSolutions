#! /usr/bin/env python3

memory_location = 312051

if memory_location == 0:
    print(0)

memory_coords = []
memory_coords.append((0, 0))


def move(loc, direction):
    x1, y1 = loc
    x2, y2 = direction
    new_loc = (x1+x2, y1+y2)
    return new_loc


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


while i < memory_location:

    direction = directions[di % 4]
    for i1 in range(length):
        i += 1
        memory_coords.append(move(memory_coords[-1], direction))

    di += 1

    direction = directions[di % 4]

    for i2 in range(length):
        i += 1
        memory_coords.append(move(memory_coords[-1], direction))

    di += 1

    length += 1

memory_location_coords = memory_coords[memory_location - 1]

print(memory_location_coords)

x, y = memory_location_coords

print(abs(x) + abs(y))
