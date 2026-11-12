---
description: Arithmetic constraints over every combination of rules.
tags: [route, z3]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our checkout stacks promotions: a percentage coupon, a fixed-amount coupon, a loyalty discount capped at 15 percent, and a free-shipping threshold. Two coupons are marked exclusive of each other. Prices are integers in cents up to about a million.

Finance wants to know whether any cart total and any combination of valid promotions can produce a negative price, or can beat the 40 percent maximum discount we promised the board. There are far too many combinations to list, and the answer depends on the arithmetic. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
