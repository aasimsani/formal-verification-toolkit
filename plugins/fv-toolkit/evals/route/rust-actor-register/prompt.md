---
description: A Rust actor system whose own code is the model.
tags: [route, stateright]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

We are writing a replicated register as actors in Rust: clients send put and get, three servers replicate with a quorum. We want the design checked for linearizability before we deploy it.

We do not want a separate model in another language that can drift from the code. We want the actor code itself explored under message reordering and loss. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
