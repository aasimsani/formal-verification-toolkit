---
description: Two SQL queries that must return the same rows on every database.
tags: [route, sqlequiv]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

An analyst rewrote one of our reporting queries. The old one is `orders LEFT JOIN shipments ON shipments.order_id = orders.id WHERE shipments.carrier = 'ups' OR shipments.carrier IS NULL`, and the new one moves the carrier test into the `ON` clause and drops the `WHERE`. Both return the same rows on last month's data.

I want to know whether the two queries return the same rows on every possible content of the two tables, with NULLs and duplicate rows included, before the new one replaces the old one. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
