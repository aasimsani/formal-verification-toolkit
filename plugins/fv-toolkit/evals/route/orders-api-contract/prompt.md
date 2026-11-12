---
description: A running HTTP API checked against its own OpenAPI document.
tags: [route, schemathesis]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

We publish an OpenAPI document for our orders API. Partners report 500 responses on unusual inputs, and responses whose fields don't match the documented schema. The create, fetch, update and cancel endpoints are all described in the document.

I want the running service checked against its own document, with generated requests, including sequences like create and then fetch. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
