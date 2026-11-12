---
description: A conservation property of pipeline code.
tags: [route, near-miss, hypothesis]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our nightly import is a Python function `load(rows)` that returns `(accepted, rejected)`. It deduplicates by customer id, drops rows with a malformed date, and normalises currency codes.

Finance needs every input row to end up in exactly one of the two outputs, so the count in equals accepted plus rejected plus the duplicates we report. Last week 14 rows were in neither. I want that checked on far more input tables than our fixtures cover. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
