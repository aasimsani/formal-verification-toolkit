---
description: A claim about every request, which a list of test cases cannot settle.
tags: [route, near-miss, z3]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our authorization rules are three conditions over a user's role, the ward they are assigned to, and a chart's sensitivity level from 1 to 5. A pull request rewrites the conditions to "simplify" them, and both versions pass our forty test cases.

I want to know whether there is any combination of role, ward and sensitivity level that the new conditions allow and the old conditions deny. Forty cases cannot tell me that. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
