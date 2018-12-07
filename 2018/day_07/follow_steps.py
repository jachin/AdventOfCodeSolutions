#! /usr/bin/env python3

import fileinput
import re


class Step:
    def __init__(self, name):
        self.name = name
        self.prerequisites = set()

    def is_step_ready(self, finished_steps):
        return len(self.prerequisites.difference(finished_steps)) == 0

    def __lt__(self, other):
        return self.name < other.name

    def __str__(self):
        return self.name


def main():
    steps = {}
    for line in fileinput.input():
        r = re.match(r'Step (\w) must be finished before step (\w) can begin.', line)
        prerequisite_step_name = r[1]
        step_name = r[2]
        if step_name not in steps:
            steps[step_name] = Step(step_name)
        if prerequisite_step_name not in steps:
            steps[prerequisite_step_name] = Step(prerequisite_step_name)
        steps[step_name].prerequisites.add(prerequisite_step_name)

    finished = set()

    steps_order = []

    while len(steps) > 0:

        available = sorted(
            filter(lambda x: x.is_step_ready(finished), steps.values())
        )

        step = available[0]
        del steps[step.name]
        finished.add(step.name)

        steps_order.append(step.name)

    print(''.join(steps_order))


if __name__ == '__main__':
    main()
