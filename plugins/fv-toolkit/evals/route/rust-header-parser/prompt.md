---
description: Rust code that must not panic or overflow for any bounded input.
tags: [route, kani]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

This Rust function parses a length-prefixed header out of a byte slice. It does index arithmetic with `u32` and `usize` casts and has one small `unsafe` block.

Fuzzing has run for a week without a crash. I want something stronger for this one function: a check of the real Rust code for every input up to 64 bytes that there is no panic, no out-of-bounds access and no arithmetic overflow. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
