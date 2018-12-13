#! /usr/bin/env python3

import fileinput
import re
import string


def get_extra_amount_by_step_name(name):
    return string.ascii_uppercase.find(name) + 1


class Step:
    def __init__(self, name):
        self.name = name
        self.prerequisites = set()
        self.time_to_complete = get_extra_amount_by_step_name(name) + 60
        self.time_so_far = 0

    def tick(self):
        self.time_so_far += 1
        return self.time_so_far >= self.time_to_complete

    def is_step_ready(self, finished_steps):
        return len(self.prerequisites.difference(finished_steps)) == 0

    def __lt__(self, other):
        return self.name < other.name

    def __str__(self):
        return "{} - {}".format(self.name, self.time_to_complete)


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
        steps[step_name].prerequisites.add(steps[prerequisite_step_name])

    finished = set()
    in_progress = set()

    steps_order = []
    number_of_workers = 5
    number_of_seconds = 0

    while (len(steps) > 0 or len(in_progress) > 0) and number_of_seconds < 2000:

        available = sorted(
            filter(lambda x: x.is_step_ready(finished), steps.values())
        )

        # Start as many steps as we can.
        for available_step in available:
            if len(in_progress) < number_of_workers:
                in_progress.add(available_step)
                del steps[available_step.name]

        # Perform 1 second of activity on all the steps in progress.
        still_in_progress = set()
        for in_progress_step in in_progress:
            if in_progress_step.tick():
                finished.add(in_progress_step)
                steps_order.append(in_progress_step.name)
            else:
                still_in_progress.add(in_progress_step)
        in_progress = still_in_progress

        number_of_seconds += 1

    print(number_of_seconds)


if __name__ == '__main__':
    main()
