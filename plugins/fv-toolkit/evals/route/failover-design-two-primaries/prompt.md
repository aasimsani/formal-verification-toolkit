---
description: A design question that has no code yet.
tags: [route, near-miss, tlaplus]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

We are designing failover for a database proxy and no code exists yet. A health checker promotes the replica when the primary misses three heartbeats, and the old primary demotes itself when it sees a higher epoch number.

Before we build it, I want to know whether some ordering of a network partition, a slow heartbeat and a promotion gives two nodes that both accept writes as the primary. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
