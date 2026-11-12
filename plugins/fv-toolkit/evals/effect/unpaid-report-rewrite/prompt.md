---
description: A rewrite moves a filter into a join condition and returns extra rows. A bounded equivalence check must find the table.
tags: [effect, sqlequiv]
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Write, Edit, Bash, Glob, Grep, Skill]
---

`reports/unpaid_old.sql` is the query behind our unpaid-invoices report. `reports/unpaid_new.sql` is a rewrite that an analyst wants to ship, and `reports/schema.sql` has the two tables. Both queries return the same rows on last month's data.

The property is this: the two queries return the same rows on every content of the two tables, with NULLs and duplicate rows included. It is confirmed, so don't stop to ask me about it or about anything else. Work through to the end.

Check it with a real run and not by reading the SQL. Put everything you write under `formal/`. Finish with a short report in `formal/REPORT.md` that gives the smallest table contents on which the two queries differ, if they do.
