---
description: A slow worker outlives its lease and a second worker repeats the job. A seeded simulation of the real code must find the schedule.
tags: [effect, dst]
max_turns: 70
timeout_seconds: 1500
allowed_tools: [Read, Write, Edit, Bash, Glob, Grep, Skill]
---

`reminders/queue.py` and `reminders/worker.py` send payment reminders. Two customers got the same reminder twice last week. It happens a few times a month and we have never reproduced it. We believe the design is fine and the code is wrong, so a model of the design would not help.

The property is this: no reminder is sent twice. It is confirmed, so don't stop to ask me about it or about anything else. Work through to the end.

Run the real `Queue` and `Worker` code through many schedules with slow workers and crashes injected, in a way that lets us replay the exact run that fails. Put everything you write under `formal/`. Finish with a short report in `formal/REPORT.md` that gives the seed of a failing run and the steps of that run.
