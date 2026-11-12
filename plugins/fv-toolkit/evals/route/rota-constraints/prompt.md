---
description: A rule set that may contradict itself or leave a gap.
tags: [route, z3]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our on-call rota has rules like: nobody works two shifts that overlap, nobody works more than five nights in a row, every shift has at least one senior, and people on leave are never assigned. The rules live in a config file as numeric bounds and time windows.

Before we feed them to the scheduler, I want to know two things: whether the rules contradict each other for next month's headcount, and whether the new "at most 50 hours a week" rule is already implied by the others. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
