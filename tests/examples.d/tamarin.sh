# needs: fv-install --check tamarin
# Example checks for the fv-tamarin skill. tests/test_examples.sh sources this file.

A="$K/fv-tamarin/examples"

t "signed-challenge: the chosen design's authentication lemma verifies" 0 "PASS check Authentication: verified" \
  fv-tamarin "$A/good/signed-challenge/challenge.spthy"
t "signed-challenge: the rejected design's lemma is falsified by a replay" 0 "PASS check Authentication: falsified" \
  fv-tamarin "$A/good/signed-challenge/challenge-unbound.spthy"
t "signed-challenge: every planted bug in the chosen design is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/signed-challenge/challenge.mutations"
t "signed-challenge: every planted bug in the rejected design is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/signed-challenge/challenge-unbound.mutations"
t "bad/dead-rule: the dead rule's lemma holds vacuously, which is the symptom" 0 "PASS check Authentication: verified" \
  fv-tamarin "$A/bad/dead-rule/dead.spthy"
t "bad/dead-rule: the executability lemma exposes the dead rule" 0 "PASS check Executability: falsified" \
  fv-tamarin "$A/bad/dead-rule/dead.spthy"

# Invariants of the fv-tamarin wrapper itself: a broken artifact reports
# ERROR, and a missing tool exits 3. This file is sourced, not run as its
# own process, so clean up the scratch directory directly instead of
# trapping EXIT, which would fire once for the whole test run.
T_TAMARIN="$(mktemp -d)"
cat > "$T_TAMARIN/broken.spthy" <<'SPTHY'
theory Broken
begin
builtins: signing
rule R:
  [ Fr(~x) ] --[ A(~x) ]-> [ Out(~x) ]
// expect: verified
lemma L:
  "All x #i. A(x @ i ==> A(x) @ i"
end
SPTHY
t "fv-tamarin reports ERROR for a theory tamarin-prover cannot parse" 1 "^ERROR broken.spthy: tamarin-prover reported no summary" \
  fv-tamarin "$T_TAMARIN/broken.spthy"
t "fv-tamarin exits 3 when tamarin-prover or maude is missing" 3 "^UNAVAILABLE tamarin" \
  env FV_HOME="$T_TAMARIN/empty" fv-tamarin "$A/good/signed-challenge/challenge.spthy"
rm -rf "$T_TAMARIN"
