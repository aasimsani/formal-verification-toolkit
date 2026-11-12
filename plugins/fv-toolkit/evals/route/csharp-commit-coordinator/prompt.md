---
description: A protocol in C#, so the model cannot be the code.
tags: [route, near-miss, tlaplus]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our order service is written in C#. It coordinates a payment service and an inventory service with a commit protocol: prepare both, then commit both, with a timeout that aborts. During an incident the coordinator restarted between the two commits and one side stayed prepared for an hour.

I want to know whether any ordering of a coordinator restart, a timeout and a late reply leaves a participant blocked or leaves the two sides disagreeing. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
