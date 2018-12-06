#! /usr/bin/env python3

import fileinput

boxes = []


def search_boxes(box, other_boxes):
    for other_box in other_boxes:
        diffs = 0
        ans = ''
        for i, bc in enumerate(list(box)):
            if bc != other_box[i]:
                diffs += 1
            else:
                ans += bc
            if diffs > 1:
                continue
        if diffs == 1:
            return ans
    return None


for line in fileinput.input():
    boxes.append(line.strip())


for i, box in enumerate(boxes):
    r = search_boxes(box, boxes[i:])
    if r:
        print(r)
        break
