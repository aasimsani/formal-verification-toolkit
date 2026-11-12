---
description: A security protocol against an attacker who controls the network.
tags: [route, tamarin]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

We are designing the unlock protocol between a key fob and a garage door controller: the fob sends a counter and a MAC over the counter under a shared key, and the controller accepts any counter that is ahead of the last one it saw, within a window of 16. An attacker can record, jam, replay and inject any radio message.

I want to know whether that attacker can open the door with a message the owner sent earlier, or with one the controller never received. This is about the protocol design, and no firmware exists yet. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
