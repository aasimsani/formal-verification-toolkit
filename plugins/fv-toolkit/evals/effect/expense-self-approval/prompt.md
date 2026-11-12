---
description: Deputy assignments let a person approve their own expense. A model of the structure must find the arrangement.
tags: [effect, alloy]
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Write, Edit, Bash, Glob, Grep, Skill]
---

`policy/approvals.py` decides who may approve an expense, from the reporting lines and the deputy assignments in `policy/org.yaml`. Audit asked whether any arrangement of reporting lines and deputies lets a person approve their own expense. Nothing here depends on timing. It is a question about which arrangements can exist.

The property is this: nobody approves their own expense. It is confirmed, so don't stop to ask me about it or about anything else. Work through to the end.

Check it with a real analyzer run and not by reading the code. Put the model and everything else you write under `formal/`. Finish with a short report in `formal/REPORT.md`.
