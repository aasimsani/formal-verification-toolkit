---
description: Real Rust concurrency under controlled thread schedules.
tags: [route, shuttle]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our Rust crate has a bounded work queue built on `Mutex` and `Condvar`. The unit tests pass. In production a worker hangs about once a week, and we think a wakeup gets lost.

I want to run the real queue code under a great many thread schedules, or every schedule for a small case, and get back the schedule that hangs so we can replay it. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
