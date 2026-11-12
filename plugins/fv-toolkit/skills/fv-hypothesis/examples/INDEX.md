# Hypothesis examples

`tests/test_examples.sh` in the repository runs every row of this table. A good test file detects every planted bug. A bad test file misses the planted bug, which is the symptom its README states.

| Example | Kind | Pattern | The one lesson |
|---|---|---|---|
| [allocation](allocation/README.md), `test_allocate.py` | good | Money and rounding (F3) | One property per claim in the docstring: conservation, a bound on each part, order independence |
| [allocation](allocation/README.md), `test_bad_tautology.py` | bad | Any | An assertion whose two sides both come from the function under test cannot fail |
| [allocation](allocation/README.md), `test_bad_vacuous_assume.py` | bad | Any | A filter that removes the interesting inputs leaves a correct assertion with nothing to check |
| [allocation](allocation/README.md), `test_bad_weak_property.py` | bad | Any | A property about the shape of the result passes on almost every bug |
| [lru-cache](lru-cache/README.md) | good | Caching, repository against a dict model (A2) | Random call sequences against a plain model find bugs that need five calls to show |

## Anti-patterns without a reproduced example yet

`../references/anti-patterns.md` describes each of these.

- Mocks inside the property
- A property that the code never claims
- A random seed in CI with no pinned failures
