---
description: A change to authorization policies written in Cedar, judged on a list of cases.
tags: [route, cedar]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our authorization policies are written in Cedar, with a schema for clinicians, wards and patient charts. A pull request rewrites three policies to "simplify" them.

Security keeps a list of about sixty access cases with the decision each one must get, such as "a clinician opens a chart from a ward they are not assigned to: deny". Before we merge, I want the rewritten policies validated against the schema and every one of those cases checked, so that a case that flips from deny to allow fails the build. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
