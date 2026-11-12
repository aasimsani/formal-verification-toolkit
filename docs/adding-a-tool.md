# Adding a tool

One tool is one pull request. This page is the contract for that pull request. The three core skills, `fv-tlaplus`, `fv-hypothesis` and `fv-alloy`, are the worked instances. Read the one closest to your tool before you write anything.

## Files

```text
plugins/fv-toolkit/
  scripts/installers/<tool>         the on-demand installer
  scripts/fv-<tool>                 a wrapper, only when the tool's own output has no verdict lines
  skills/fv-<tool>/
    SKILL.md
    references/                     facts measured on the pinned version, anti-patterns
    examples/INDEX.md
    examples/good/<name>/           the artifact, its mutations file, a README
    examples/bad/<name>/            a broken artifact and a README with its real output
tests/examples.d/<tool>.sh          the checks that run every example
```

A tool pull request adds these files and one row in each of three shared places: `plugins/fv-toolkit/references/skills.md`, the skills table in `README.md`, and `NOTICE.md` when text was adapted.

## The installer

`scripts/installers/<tool>` is an executable that `fv-install <tool>` runs. A tool is installed only when someone names it.

- With no argument, it installs the tool if it is missing and prints `READY <tool> <path or version>`.
- With `--check`, it reports the state and installs nothing.
- When it cannot make the tool ready, it prints `UNAVAILABLE <tool>: <remedy>` and exits 3. The remedy is one sentence that tells the user what to install or run.
- It pins a version. A file it downloads is verified against a SHA-256 written in the installer.
- It installs under `$FV_HOME/<tool>/`, which defaults to `~/.cache/fv/<tool>/`, or it runs the tool through an isolated runner such as `uv run --with <package>==<version>`. It never uses `sudo`, and it never installs a package globally.
- It checks its own prerequisites, such as Java, cargo, dotnet or node, and reports a missing one as `UNAVAILABLE`.

## Verdict lines

`fv-mutate` decides that a planted bug was detected when the check exits non-zero and one output line holds both `FAIL` and the name of the property. A tool therefore needs output of this shape:

```text
PASS <kind> <name>: <outcome>
FAIL <kind> <name>: expected <outcome>, got <outcome>
ERROR <thing>: <reason>            the tool could not check the artifact
UNAVAILABLE <tool>: <remedy>       exit 3: nothing was checked
```

pytest prints `FAILED path::test_name`, which already fits. When a tool prints nothing of this shape, add a wrapper `scripts/fv-<tool>` that runs the tool and prints these lines. Exit 0 when everything matches, 1 on a `FAIL` or an `ERROR`, 2 on a usage error and 3 when the tool is missing. Give every expected result a place in the artifact itself, as `fv-tlc` reads the `\* expect:` header of a config.

A wrapper must report a tool error as `ERROR`. A broken artifact must never count as the violation that a check expects.

## The skill file

The frontmatter has `name: fv-<tool>` and a `description` of at most 1,024 characters. The description says what the skill does, when to use it, and what it is not for, with the skill to use in that case.

Write the sections in this order, in about 130 lines:

1. Two or three sentences on what the tool tries and what it returns.
2. A pointer for a reader who came directly: run steps 1 to 3 of the `formal-verification` skill first.
3. **Five rules.** The five mistakes that make a check with this tool pass while it proves nothing, each as a rule.
4. **Files to write**, as a table.
5. **Workflow**, as numbered steps with the exact commands. Write script paths as `${CLAUDE_PLUGIN_ROOT}/scripts/<name>`.
6. **Reading the output**, as a table from each verdict line to its meaning.
7. **Telling a counterexample**, with a short example in the system's own words.
8. **Examples** and **References**.

State what a pass means for this tool: exhaustive within a bound, a search, or a proof.

## Examples

Every statement an example makes is one that the test suite reproduces.

- **A good example** is small and complete. Its README gives the pattern with its catalog id, what the example teaches, the system, the property ledger, a table of configs or commands with the declared outcome of each, the run commands, one counterexample as numbered steps, and the bounds and limits.
- **A good example has a mutations file.** Every mutation prints `DETECTED`, one harmless edit prints `GREEN`, and no property is `UNCOVERED`. `plugins/fv-toolkit/references/bite.md` describes the file.
- **A good example declares a rejected design.** A check that must fail sits beside the check that must pass, and a witness shows that the interesting state is reachable.
- **A bad example is broken on purpose.** Its README gives the symptom, the real output, why the artifact is wrong, the fix, and the check that catches the error. When no mechanical check catches it, say so.
- **Ship at least as many bad examples as good ones.** The symptom of most errors is "it passes", and only a reproduced example shows that.
- **Quote only real output.** Every output in a README comes from a run of the pinned tool on the shipped file. Never write an output from memory.
- **Names carry no verdicts.** Name a config, a constant or a command for its mechanism. `CheckThenRefund` is a mechanism. `Buggy` is a verdict.
- **Put a sync record in each artifact**, in a comment: `Source read at: 0000000` and `Covers: <path>`. An example describes no real repository, so the commit is a placeholder, and the comment says that.

## Tests

`tests/examples.d/<tool>.sh` is sourced by `tests/test_examples.sh`. Its first line is `# needs: <command>`, and the file is skipped when that command fails. Use `fv-install --check <tool>` as the command.

```bash
# needs: fv-install --check alloy
A="$K/fv-alloy/examples"

t "rbac: every command meets its expectation" 0 "PASS check NoEscalationWhenAnyoneAdmins: SAT" \
  fv-alloy "$A/good/rbac/rbac.als"
t "bad/overconstraint: the false claim passes, which is the symptom" 1 "PASS check NobodyHoldsARole: UNSAT" \
  fv-alloy "$A/bad/overconstraint/overconstrained.als"
```

`t` takes a name, the exit code that must occur, a regex that the output must match, and the command. `$K` is the skills directory, `$S` is the scripts directory and `$ROOT` is the repository root. Write one row per claim that a README makes. Name each row for the invariant it protects.

A wrapper script gets rows in `tests/test_scripts.sh`, for the same invariants as `fv-tlc` and `fv-alloy`: a pass only when the outcome equals the declared one, an `ERROR` for a broken artifact, and exit 3 when the tool is missing.

Run the suites before you commit:

```bash
plugins/fv-toolkit/scripts/fv-install <tool>
bash tests/test_examples.sh <tool>
bash tests/test_scripts.sh
bash tests/test_structure.sh
```

CI runs `FV_REQUIRE=1 bash tests/test_examples.sh <tool>` for each tool whose files changed, so a skipped tool fails there.

## Done

- [ ] `fv-install <tool>` prints `READY`, and `fv-install --check <tool>` installs nothing
- [ ] Every good example meets its declared outcomes and detects every mutation
- [ ] Every bad example produces the symptom that its README quotes
- [ ] Every fact under "measured on version X" was reproduced with a shipped file
- [ ] The three suites pass
- [ ] `references/skills.md` has a row for the tool, and the README table has a row for the skill

## Prose

The skill files and READMEs are technical writing, and the reader is an agent in the middle of a task or a person who has not used the tool.

- Write complete sentences with a subject and a verb. Do not open a sentence with a label and a colon.
- Write one claim per sentence, and join a reason with "because" or "so".
- Use no metaphors. Write the mechanism.
- Use the tool's own terms and the names in the files. Do not coin a second name for a thing.
- Use a colon only before a list or a code block.
- Say what a missing safeguard lets happen. "Nothing stops two jobs from reading the same balance" is clearer than "no locking".

## Sources and licenses

This repository is MIT licensed.

- Text or code may be adapted from an MIT or Apache-2.0 source. Add a row to `NOTICE.md` with the source, the license, the revision that was read and what was adapted.
- A GPL, CC-BY-SA or unlicensed source contributes ideas only. Write the text and the code again from the tool's own documentation and from your own runs.
- An example may model a well-known algorithm or protocol. Write the model yourself, and do not vendor a file whose license you have not read.
