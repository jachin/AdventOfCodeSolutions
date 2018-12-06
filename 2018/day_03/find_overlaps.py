#! /usr/bin/env python3

import fileinput


class Claim:
    def __init__(self, s):
        [claim_id, at, corner, dimensions] = s.split(' ')
        self.claim_id = claim_id
        [x, y] = corner[:-1].split(',')
        [w, h] = dimensions.split('x')
        self.x = int(x)
        self.y = int(y)
        self.w = int(w)
        self.h = int(h)

    def __str__(self):
        return "{} @ {},{}: {}x{}".format(self.claim_id, self.x, self.y, self.w, self.h)


claims = []
fabric = {}

for i in range(1000):
    for j in range(1000):
        fabric[(i, j)] = 0

for line in fileinput.input():
    c = Claim(line)
    claims.append(c)


for claim in claims:
    for i in range(claim.w):
        for j in range(claim.h):
            x = claim.x + i
            y = claim.y + j
            fabric[(x, y)] += 1

multiple_claims = 0

for sq in fabric.values():
    if sq > 1:
        multiple_claims += 1

print(multiple_claims)
