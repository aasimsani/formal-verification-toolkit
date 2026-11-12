---
description: A request to debug a flaky CI job must not load a verification skill.
tags: [no-trigger]
max_turns: 5
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
---

Our CI job fails about one run in ten with `ECONNRESET` while it downloads npm packages, and passes on a rerun. What are the two or three most likely causes and the usual fixes?
