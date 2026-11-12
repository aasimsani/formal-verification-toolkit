---
description: A request for one ordinary unit test must not load a verification skill.
tags: [no-trigger]
max_turns: 5
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
---

Add one pytest for the happy path of this function, nothing fancy:

```python
def full_name(first: str, last: str) -> str:
    return f"{first.strip()} {last.strip()}"
```

Just show me the test.
