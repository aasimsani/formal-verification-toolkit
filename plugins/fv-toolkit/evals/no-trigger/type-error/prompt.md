---
description: A typing question must not load a verification skill.
tags: [no-trigger]
max_turns: 5
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
---

mypy says `Incompatible return value type (got "Optional[str]", expected "str")` on this line: `return os.environ.get("HOME")`. What's the shortest correct fix?
