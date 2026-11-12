# Tools that have a skill

Pick the row whose question matches the claim, load that skill, and install the tool if it is missing. `fv-install <name>` installs one tool. `fv-install` with no argument installs the two core jars.

## Core tools

| The question is | Tool | Skill | Install |
|---|---|---|---|
| Can a bad ordering happen? Concurrency, retries, crashes, message loss, leases | TLA+ with TLC | `fv-tlaplus` | `fv-install tla` |
| Can the data or the configuration reach an invalid shape? Relations, permissions, ownership, compatibility | Alloy 6 | `fv-alloy` | `fv-install alloy` |
| Is this Python code correct for every input, or for every sequence of calls? | Hypothesis | `fv-hypothesis` | The project's package manager |

## On-demand tools

Each of these tools installs when it is named. Load its skill first, because the skill says what the installer needs.

| The question is | Tool | Skill | Install |
|---|---|---|---|
| Does a rule table, a policy or a set of numeric constraints have a gap, an overlap or a contradiction? Arithmetic and boolean conditions over a few variables | Z3 | `fv-z3` | `fv-install z3` |
| Does a running HTTP API keep to its OpenAPI schema, for single requests and for sequences of calls such as create, get, delete? | Schemathesis | `fv-schemathesis` | `fv-install schemathesis` |
| Do two versions of a pure Python function ever disagree, or does one small pure function break its own contract on some input? | CrossHair | `fv-crosshair` | `fv-install crosshair` |
| Can real Rust code deadlock or lose an update under some thread interleaving? | Shuttle and Loom | `fv-shuttle` | `fv-install shuttle` |

A tool that is not in this file has no skill yet. Read `tools.md`, say that no skill covers the tool, and follow the router's workflow from the tool's own documentation.
