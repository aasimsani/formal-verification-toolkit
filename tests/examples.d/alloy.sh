# needs: fv-install --check alloy
# Example checks for the fv-alloy skill. tests/test_examples.sh sources this file.

A="$K/fv-alloy/examples"

t "rbac: every command meets its expectation" 0 "PASS check NoEscalationWhenAnyoneAdmins: SAT" \
  fv-alloy "$A/good/rbac/rbac.als"
t "rbac: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/rbac/rbac.mutations"
t "bad/overconstraint: the check passes on a model with no instance, and the run exposes it" 1 "FAIL run SomeUsers: expected SAT, got UNSAT" \
  fv-alloy "$A/bad/overconstraint/overconstrained.als"
t "bad/overconstraint: the false claim passes, which is the symptom" 1 "PASS check NobodyHoldsARole: UNSAT" \
  fv-alloy "$A/bad/overconstraint/overconstrained.als"
t "bad/vacuous-in: the weak assertion passes and the strong one finds the empty case" 0 "PASS check EveryUserHoldsAnApprovedRole: SAT" \
  fv-alloy "$A/bad/vacuous-in/approved.als"
t "bad/fact-forbids-the-bug: the claim passes because a fact assumes it, which is the symptom" 0 "PASS check NoEscalation: UNSAT" \
  fv-alloy "$A/bad/fact-forbids-the-bug/rbac_fact.als"
