# needs: command -v uv
# Example checks for the fv-hypothesis skill. tests/test_examples.sh sources this file.

# These examples need Hypothesis and pytest. uv supplies both for the run.
H="$K/fv-hypothesis/examples"
py() { uv run --quiet --with hypothesis --with pytest "$@"; }

t "allocation: every planted bug is detected" 0 'uncovered=0' \
  py fv-mutate "$H/allocation/allocate.mutations"
t "lru-cache: the state machine detects every planted bug" 0 'uncovered=0' \
  py fv-mutate "$H/lru-cache/lru.mutations"
t "allocation/bad tautology: the planted bug is missed, which is the symptom" 1 '^MISSED the leftover cents are dropped' \
  py fv-mutate "$H/allocation/bad_tautology.mutations"
t "allocation/bad vacuous assume: the planted bug is missed, which is the symptom" 1 '^MISSED the leftover cents are dropped' \
  py fv-mutate "$H/allocation/bad_vacuous_assume.mutations"
t "allocation/bad weak property: every planted bug is missed, which is the symptom" 1 'detected=0 missed=3' \
  py fv-mutate "$H/allocation/bad_weak_property.mutations"
