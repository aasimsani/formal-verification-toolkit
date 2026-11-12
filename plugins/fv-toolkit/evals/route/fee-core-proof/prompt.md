---
description: A small core where a sampled check is not enough.
tags: [route, dafny]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our settlement fee calculation is about forty lines of integer arithmetic with a loop over tiers. Regulators hold us to it, and a wrong cent is a reportable incident. Property tests have passed for years.

For this one function, sampled inputs are no longer enough for the risk committee. They want a machine-checked argument that the postconditions hold for every input of any size, and they accept that we write the core in a language built for that and generate the production code from it. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
