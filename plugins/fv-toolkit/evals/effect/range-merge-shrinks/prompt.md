---
description: A merge of date ranges loses days when one range sits inside another. Generated inputs must find it.
tags: [effect, hypothesis]
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Write, Edit, Bash, Glob, Grep, Skill]
---

`billing/ranges.py` has a `merge` function for billing periods. Billing found merged periods that are shorter than one of the periods that went in.

The promises in the function's docstring are the properties we stand behind. They are confirmed, so don't stop to ask me about them or about anything else. Work through to the end.

Check the function against generated inputs, and not against a handful of hand-picked ones. Put the tests in `tests/test_merge_properties.py`, show that they fail on a planted bug, and finish with a short report in `REPORT.md` that gives the smallest input you found for which the function is wrong.
