# needs: fv-install --check z3
# Example checks for the fv-z3 skill. tests/test_examples.sh sources this file.

A="$K/fv-z3/examples"

t "shipping-tiers: every command meets its expectation" 0 "PASS check RejectedDesignOverlapsAtTheBoundary: sat" \
  fv-z3 "$A/good/shipping-tiers/shipping.py"
t "shipping-tiers: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/shipping-tiers/shipping.mutations"
t "policy-containment: every command meets its expectation" 0 "PASS check TightenedPolicyAllowsNothingTheOldOneDenied: unsat" \
  fv-z3 "$A/good/policy-containment/policy.py"
t "policy-containment: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/policy-containment/policy.mutations"
t "bad/existence-not-universality: the wrong check passes on a real gap, which is the symptom" 1 "PASS check SomeWeightMatchesATier: sat" \
  fv-z3 "$A/bad/existence-not-universality/tiers_with_a_gap.py"
t "bad/existence-not-universality: the check beside it finds the same gap" 1 "FAIL check EveryWeightMatchesATier: expected unsat, got sat" \
  fv-z3 "$A/bad/existence-not-universality/tiers_with_a_gap.py"
t "bad/unknown-read-as-pass: the naive script reads unknown as a pass, which is the symptom" 0 "^PASS NoChargebackCombination" \
  uv run --quiet --no-project --with z3-solver==5.4.1 python "$A/bad/unknown-read-as-pass/naive_check.py"
t "bad/unknown-read-as-pass: fv-z3 reports the same run as an error" 1 "^ERROR check NoChargebackCombination: z3 returned unknown" \
  fv-z3 "$A/bad/unknown-read-as-pass/fixed_check.py"
t "fv-z3 exits 3 when uv is missing" 3 "^UNAVAILABLE z3" \
  env PATH="$S:/usr/bin:/bin" fv-z3 "$A/good/shipping-tiers/shipping.py"

Z3_BROKEN="$(mktemp -t fv-z3-broken).py"
printf 'def check_Broken(\n' > "$Z3_BROKEN"
t "fv-z3 reports a broken artifact as an error, never as the violation a check expects" 1 "^ERROR .*: SyntaxError" \
  fv-z3 "$Z3_BROKEN"
rm -f "$Z3_BROKEN"
