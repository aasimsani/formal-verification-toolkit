---
description: Which configurations of people, deputies and rules can exist.
tags: [route, alloy]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our expense rules: an expense needs approval from the requester's manager. A manager can name a deputy who approves on their behalf, and a deputy can name a deputy of their own. Org structure and deputy assignments are plain configuration, and nothing here depends on timing.

Audit asked a yes-or-no question: is there any arrangement of reporting lines and deputy assignments in which a person ends up approving their own expense? We can't enumerate the arrangements by hand. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
