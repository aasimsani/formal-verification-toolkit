---
description: A single-threaded object whose bugs need long call sequences.
tags: [route, hypothesis]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our editor's history class has `apply(edit)`, `undo()` and `redo()`, and it is used from one thread only. A bug report says a redo brought back an edit that had been undone and then replaced by a new edit, and it only happens after some run of six or seven calls that nobody can reconstruct.

I want something that tries a great many call sequences against the class and hands me the shortest one that goes wrong. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
