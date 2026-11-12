---
description: Python functions that already carry contracts.
tags: [route, crosshair]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our pricing helpers are plain Python functions with type hints, and each one already has `assert` statements for its preconditions and a docstring postcondition, like "the result is never negative". I refactored three of them last week.

I don't want to write test generators. I want a tool that reads the contracts that are already in the code, searches for an input that breaks one, and also tells me any input on which an old function and its refactored version give different results. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
