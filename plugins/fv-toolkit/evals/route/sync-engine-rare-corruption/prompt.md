---
description: The real code of a whole system under injected faults, with replay.
tags: [route, dst]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our offline-first sync engine is about four thousand lines of Python: three replicas exchange edit logs over an unreliable link and merge them. The tests pass. In production a replica ends up with a document that no sequence of edits could have produced, roughly once a month, after a partition and a process crash happen close together. We have never reproduced it.

A model of the design would not help, because we believe the merge design is right and the code is wrong. I want to run the real code through thousands of schedules with partitions, crashes and message loss injected, and be able to replay the exact run that fails. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
