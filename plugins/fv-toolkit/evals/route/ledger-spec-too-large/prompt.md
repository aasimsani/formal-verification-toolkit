---
description: A TLA+ spec whose integer ranges are too large to enumerate.
tags: [route, tlaplus]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

We already have a TLA+ spec of our wallet ledger, and TLC checks it for balances up to 3. Real balances and transfer amounts are integers up to several million, and one bug class we worry about only shows when an amount is larger than the sum of two others. TLC runs out of memory long before it reaches those values.

I want the invariant "no balance is ever negative and the total is conserved" checked for every integer value, for executions of up to ten steps, without enumerating the values one by one. I also want to know whether that invariant is inductive. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
