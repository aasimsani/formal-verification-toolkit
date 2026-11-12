---
description: Path coverage for a UI flow defined as an XState machine.
tags: [route, xstate]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our loan application flow is an XState machine with about fifteen states: applicant details, income, documents upload, credit check, offer, and error and retry states around the credit check. Testers keep missing paths, like going back from the offer after a failed credit check.

I want tests generated from the machine itself, so that every state and every transition is reached by some test, and each test drives the real UI code. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
