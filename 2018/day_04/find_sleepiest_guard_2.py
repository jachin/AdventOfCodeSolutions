#! /usr/bin/env python3

import fileinput
import re
from datetime import datetime
from collections import deque


class Guard:
    def __init__(self, guard_id=None):
        self.guard_id = int(guard_id)
        self.shifts = []

    def add_shift(self, shift):
        self.shifts.append(shift)

    def total_sleep(self):
        total = 0
        for shift in self.shifts:
            total += shift.total_sleep()
        return total

    def sleepiest_minute(self):
        minutes = self.tally_minutes()
        return max(minutes, key=minutes.get)

    def tally_minutes(self):
        minutes = {}
        for shift in self.shifts:
            for i in range(1, 60):
                if shift.napping_at_minute(i):
                    minutes[i] = minutes.setdefault(i, 0) + 1
        return minutes

    def sleepiest_minute_value(self):
        sleepiest_minute_values = list(self.tally_minutes().values())
        if len(sleepiest_minute_values) < 1:
            return 0
        return max(sleepiest_minute_values)

    def __lt__(self, other):
        return self.sleepiest_minute_value() < other.sleepiest_minute_value()


class GuardShift:
    def __init__(self, guard_id, datetime):
        self.guard_id = guard_id
        self.datetime = datetime
        self.naps = []

    def add_nap(self, start, end):
        self.naps.append((start, end))

    def napping_at_minute(self, minute):
        for nap in self.naps:
            (start, end) = nap
            if minute >= start.minute and minute < end.minute:
                return True
        return False

    def total_sleep(self):
        total = 0
        for nap in self.naps:
            (start, end) = nap
            duration = end - start
            total += int(duration.total_seconds() / 60)
        return total


log_regex = r'^\[([^\]]*)\] (.*)'


class LogEntry:

    FALLS_ASLEEP = 'FALLS ASLEEP'
    WAKES_UP = 'WAKES UP'
    BEGIN_SHIFT = 'BEGIN SHIFT'

    def __init__(self, str):
        (datetime_str, entry) = re.match(log_regex, str).groups()
        self.datetime = datetime.strptime(datetime_str, '%Y-%m-%d %H:%M')
        self.entry = entry
        if entry == 'falls asleep':
            self.type = LogEntry.FALLS_ASLEEP
            self.guard_id = None
        elif entry == 'wakes up':
            self.type = LogEntry.WAKES_UP
            self.guard_id = None
        else:
            self.type = LogEntry.BEGIN_SHIFT
            self.guard_id = re.match(r'Guard #(\d+)', entry).group(1)

    def __lt__(self, other):
        return self.datetime < other.datetime

    def __str__(self):
        return "[{}] {} {} {}".format(
            self.datetime.strftime("%A, %d. %B %Y %I:%M%p"),
            self.entry,
            self.type,
            self.guard_id
        )


entries = []
for line in fileinput.input():
    entries.append(LogEntry(line))

entries.sort()

guards = {}

stack = deque()
for entry in entries:
    if entry.type == LogEntry.BEGIN_SHIFT:
        if len(stack) > 0:
            old_shift = stack.pop()
            guards[old_shift.guard_id].add_shift(old_shift)
        if entry.guard_id not in guards:
            guards[entry.guard_id] = Guard(entry.guard_id)

        guard = guards[entry.guard_id]
        shift = GuardShift(guard_id=entry.guard_id, datetime=entry.datetime)

        stack.append(shift)
    elif entry.type == LogEntry.FALLS_ASLEEP:
        stack.append(entry)
    elif entry.type == LogEntry.WAKES_UP:
        nap_start_entry = stack.pop()
        shift = stack.pop()
        shift.add_nap(nap_start_entry.datetime, entry.datetime)
        stack.append(shift)

gaurds_list = list(guards.values())
gaurds_list.sort()

sleepiest_guard = gaurds_list[-1]

print(sleepiest_guard.sleepiest_minute() * sleepiest_guard.guard_id)