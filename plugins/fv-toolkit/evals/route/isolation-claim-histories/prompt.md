---
description: Recorded transaction histories checked against an isolation claim.
tags: [route, elle]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our storage layer claims snapshot isolation. During a staging run we recorded histories from sixteen concurrent clients: each transaction is a list of reads and appends on keys, with what each read returned.

I want those recorded histories checked for any anomaly that contradicts the claim, and I want to know which isolation level the histories are actually consistent with. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
