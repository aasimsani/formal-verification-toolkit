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

t "rebac: the rejected rewrite rule finds the unintended edit path" 0 "PASS check NoUnintendedEditFromAncestorViewer_EditorOrViewerChain: SAT" \
  fv-alloy "$A/good/rebac/rebac.als"
t "rebac: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/rebac/rebac.mutations"

t "schema-compat: the no-rule design finds an incompatible live pair" 0 "PASS check AllLivePairsCompatible_NoRule: SAT" \
  fv-alloy "$A/good/schema-compat/schema-compat.als"
t "schema-compat: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/schema-compat/schema-compat.mutations"

t "scd2: the no-rule design finds an overlap" 0 "PASS check NoOverlap_NoRule: SAT" \
  fv-alloy "$A/good/scd2/scd2.als"
t "scd2: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/scd2/scd2.mutations"

t "lineage-pii: the direct-only rule misses a derived column" 0 "PASS check NoUnmaskedPIIAtASink_MaskingCoversDirectPIIOnly: SAT" \
  fv-alloy "$A/good/lineage-pii/lineage-pii.als"
t "lineage-pii: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/lineage-pii/lineage-pii.mutations"

t "tenant-isolation: the no-rule design finds a cross-tenant read" 0 "PASS check NoCrossTenantRead_NoRule: SAT" \
  fv-alloy "$A/good/tenant-isolation/tenant-isolation.als"
t "tenant-isolation: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$A/good/tenant-isolation/tenant-isolation.mutations"

t "bad/lax-frame-conditions: the unframed field breaks a property that should hold, which is the symptom" 1 "FAIL check LockPreservesAlarm: expected UNSAT, got SAT" \
  fv-alloy "$A/bad/lax-frame-conditions/doorsystem.als"
