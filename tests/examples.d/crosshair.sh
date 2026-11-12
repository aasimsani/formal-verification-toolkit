# needs: fv-install --check crosshair
# Example checks for the fv-crosshair skill. tests/test_examples.sh sources this file.

A="$K/fv-crosshair/examples"

t "split-evenly: every command meets its expectation" 0 "PASS diff RejectedDesignPutsExtraCentsLast: differs" \
  fv-crosshair "$A/good/split-evenly/money.crosshair"
t "split-evenly: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/split-evenly/money.mutations"
t "bad/weak-contract-reads-as-proof: the weak contract holds on a real bug, which is the symptom" 0 "^PASS check WeakContractHolds: holds" \
  fv-crosshair "$A/bad/weak-contract-reads-as-proof/money.crosshair"
t "bad/weak-contract-reads-as-proof: the full contract finds the same bug" 0 "PASS check FullContractRefutesTheSameBug: refuted" \
  fv-crosshair "$A/bad/weak-contract-reads-as-proof/money.crosshair"
t "bad/nondeterministic-code-caps-the-result: holds on a function that is wrong 1 run in 256" 0 "^PASS check JitterNeverChangesTheAmount: holds" \
  fv-crosshair "$A/bad/nondeterministic-code-caps-the-result/pricing.crosshair"

t "fv-crosshair exits 3 when uv is missing" 3 "^UNAVAILABLE crosshair" \
  env PATH="$S:/usr/bin:/bin" fv-crosshair "$A/good/split-evenly/money.crosshair"

CH_BAD="$(mktemp -d)"
printf 'def broken(\n' > "$CH_BAD/broken.py"
printf 'check Broken broken.broken expect holds\n' > "$CH_BAD/broken.crosshair"
t "fv-crosshair reports a broken target as an error, never as the violation a check expects" 1 "^ERROR check Broken:" \
  bash -c "cd '$CH_BAD' && fv-crosshair broken.crosshair"
rm -rf "$CH_BAD"
