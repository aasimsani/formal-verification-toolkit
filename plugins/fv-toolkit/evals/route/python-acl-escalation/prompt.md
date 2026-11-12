---
description: Access rules in custom Python, with no policy language.
tags: [route, near-miss, alloy]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our access control is custom Python and a few tables: users belong to groups, groups can contain groups, a folder grants a role to a group, and folders inherit grants from their parent unless a folder is marked private. There is no policy language and no policy engine.

I want to know whether any arrangement of groups, nested groups and folders gives a user write access to a private folder that no grant names them for. Nothing here depends on timing. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
