---
description: A lost response and a retry between two steps of a protocol.
tags: [route, tlaplus]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our web client rotates refresh tokens: it sends the old refresh token, the server issues a new pair and revokes the old one, and the client stores the new pair. Users keep the app open in several tabs, and each tab refreshes on its own timer. Responses can arrive late or get lost when a laptop sleeps.

The claim in our security doc is "a user with a valid session is never logged out by a refresh". Support tickets say otherwise. I need to know whether some ordering of two tabs, a lost response and a retry breaks that claim. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
