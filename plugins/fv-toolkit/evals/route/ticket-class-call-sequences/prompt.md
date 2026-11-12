---
description: An in-process Python class with no HTTP layer.
tags: [route, near-miss, hypothesis]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our support desk has a `TicketBoard` Python class with `open(ticket)`, `assign(id, agent)`, `close(id)` and `reopen(id)`. There is no HTTP layer in front of it and no OpenAPI document. It is plain objects in one process.

A closed ticket showed up in an agent's queue after some sequence of reopen and assign calls. I want random sequences of calls run against the class, with its invariants checked after every call, and the shortest failing sequence reported. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
