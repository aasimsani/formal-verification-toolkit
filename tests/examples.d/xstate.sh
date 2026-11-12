# needs: fv-install --check xstate
# Example checks for the fv-xstate skill. tests/test_examples.sh sources this file.

X="$K/fv-xstate/examples"

t "checkout: the chosen design conforms to the implementation on every path" 0 "PASS path ConformsToMachine: xstate.init -> cart" \
  node "$X/good/checkout/run-paths.cjs" --machine guarded
t "checkout: the rejected design finds the witness that skipping validation is reachable" 1 "FAIL path ConformsToMachine: expected payment, got shipping on xstate.init -> NEXT -> NEXT" \
  node "$X/good/checkout/run-paths.cjs" --machine unguarded
t "checkout: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$X/good/checkout/run-paths.mutations"
t "bad/unreachable-state: the declared cancelled state is never visited, which is the symptom" 0 "4 states reached; the machine declares cart, shipping, payment, cancelled" \
  node "$X/bad/unreachable-state/list-paths.cjs"
t "bad/asserts-nothing: the planted bug is missed, which is the symptom" 1 "^MISSED setting the payment flag is dropped" \
  fv-mutate "$X/bad/asserts-nothing/weak-run.mutations"
