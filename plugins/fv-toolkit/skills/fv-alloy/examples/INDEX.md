# Alloy examples

`tests/test_examples.sh` in the repository runs every row of this table. A good example meets its expectations and detects its mutations. A bad example produces the symptom that its README states.

| Example | Kind | Pattern | The one lesson |
|---|---|---|---|
| [good/rbac](good/rbac/README.md) | good | RBAC (E), permissions on shared content (F3) | A design rule is a predicate. Check the claim under the chosen design and under the rejected one |
| [bad/overconstraint](bad/overconstraint/README.md) | bad | Any | Contradicting facts leave no instance, so a false claim passes. Only the `run` shows it |
| [bad/vacuous-in](bad/vacuous-in/README.md) | bad | Any | `x.f in S` holds when `x.f` is empty |
| [bad/fact-forbids-the-bug](bad/fact-forbids-the-bug/README.md) | bad | RBAC (E) | A design rule written as a fact makes the claim hold by assumption, and no command catches it |

## Anti-patterns without a reproduced example yet

`../references/anti-patterns.md` describes this one.

- Missing or lax frame conditions in an Alloy 6 model with `var` fields
