---
description: Whether a dependency rule can be broken through any chain.
tags: [route, alloy]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

We have a rule that `domain` modules must never depend on `infra` modules, directly or through any chain of imports, and each module belongs to exactly one layer. We also allow "shared" modules that both layers import.

Before we write a linter, I want to know whether the rules as we wrote them are even consistent: can a set of modules and imports satisfy every rule and still give `domain` a path to `infra` through a shared module? This is about which import graphs are possible. Nothing runs and nothing is ordered in time. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
