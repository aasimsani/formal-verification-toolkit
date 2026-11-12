---
description: A read followed by a write lets two buyers hold one seat. The check must find it with a real checker run.
tags: [effect, tlaplus]
max_turns: 70
timeout_seconds: 1500
allowed_tools: [Read, Write, Edit, Bash, Glob, Grep, Skill]
---

Our ticketing holds code is in `ticketing/holds.py`. Two buyers reported that they both saw "seat held" for the same seat within the same second.

The property we promise is this: two buyers never hold the same seat at the same time. That property is confirmed, so don't stop to ask me about it or about anything else. Work through to the end.

Check whether the code can break the property, with a real checker run and not by reading the code. Put the model, its configs and everything else you write under `formal/`. Finish with a short report in `formal/REPORT.md`.
