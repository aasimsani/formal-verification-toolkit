---
description: A pure function that must hold for every input.
tags: [route, hypothesis]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

This function merges overlapping date ranges:

```python
def merge(ranges: list[tuple[date, date]]) -> list[tuple[date, date]]:
    out = []
    for start, end in sorted(ranges):
        if out and start <= out[-1][1]:
            out[-1] = (out[-1][0], end)
        else:
            out.append((start, end))
    return out
```

Billing found merged ranges that are shorter than one of their inputs. The docstring promises that the result covers exactly the same days as the input, with no two ranges overlapping. It is a pure function with no I/O and no concurrency. I want it checked against far more inputs than I can think of by hand. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
