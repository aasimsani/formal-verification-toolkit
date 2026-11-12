---
description: A pattern with no invariant of its own gets no formal check.
tags: [route, no-tool]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

We have a `NotifierFactory` that returns an `EmailNotifier` or an `SmsNotifier` depending on a config string, plus a small adapter that wraps the SMS vendor's client. A colleague wants us to "formally verify" the factory and the adapter before the release.

Is that worth doing? Tell me what you'd actually check here, if anything. Don't write anything yet.
