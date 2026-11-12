# needs: command -v uv
# Example checks for the fv-schemathesis skill. tests/test_examples.sh sources this file.

# These examples need Schemathesis and pytest. uv supplies both for the run.
H="$K/fv-schemathesis/examples"
py() { uv run --quiet --with schemathesis --with pytest "$@"; }

t "items-api: schema conformance and the create/get/delete workflow both pass" 0 '^4 passed' \
  py python -m pytest -q "$H/good/items-api/test_items.py"
t "items-api: every planted bug is detected" 0 'uncovered=0' \
  py fv-mutate "$H/good/items-api/items.mutations"
t "bad/schema-too-loose: the loose schema passes on a real bug, which is the symptom" 1 '^\.F' \
  py python -m pytest -q "$H/bad/schema-too-loose/test_total.py"
t "bad/schema-too-loose: the tight schema finds the same bug" 1 'is less than the minimum of 0' \
  py python -m pytest -q "$H/bad/schema-too-loose/test_total.py"
t "bad/call-without-validate: call() alone passes on a real bug, which is the symptom" 1 '^\.\.\.F' \
  py python -m pytest -q "$H/bad/call-without-validate/test_items.py"
t "bad/call-without-validate: the validated workflow finds the same bug" 1 'Deleted resource still available' \
  py python -m pytest -q "$H/bad/call-without-validate/test_items.py"
