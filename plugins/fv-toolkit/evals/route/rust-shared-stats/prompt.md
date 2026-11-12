---
description: Rust threads that share state.
tags: [route, near-miss, shuttle]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our Rust metrics crate keeps per-endpoint counters in a `HashMap` behind an `RwLock`, with an `AtomicU64` for the total. Four worker threads record samples, and a reporter thread takes a snapshot and resets the counters every ten seconds.

The total in a snapshot is sometimes larger than the sum of the per-endpoint counters. I want the real code run under thread schedules until that mismatch is found, with the schedule that produces it. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
