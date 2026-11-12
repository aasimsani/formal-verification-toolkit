# Tools that have a skill

Pick the row whose question matches the claim, load that skill, and install the tool if it is missing. `fv-install <name>` installs one tool. `fv-install` with no argument installs the two core jars.

## Core tools

| The question is | Tool | Skill | Install |
|---|---|---|---|
| Can a bad ordering happen? Concurrency, retries, crashes, message loss, leases | TLA+ with TLC | `fv-tlaplus` | `fv-install tla` |
| Can the data or the configuration reach an invalid shape? Relations, permissions, ownership, compatibility | Alloy 6 | `fv-alloy` | `fv-install alloy` |
| Is this Python code correct for every input, or for every sequence of calls? | Hypothesis | `fv-hypothesis` | The project's package manager |

A tool that is not in this file has no skill yet. Read `tools.md`, say that no skill covers the tool, and follow the router's workflow from the tool's own documentation.
