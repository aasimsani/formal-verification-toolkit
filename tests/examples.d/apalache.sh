# needs: fv-install --check apalache
# Example checks for the Apalache extension of fv-tlaplus. tests/test_examples.sh sources this file.

G="$K/fv-tlaplus/examples/good"
B="$K/fv-tlaplus/examples/bad"

t "lease-induction: every step of the inductive proof holds" 0 'PASS Step.icfg: holds' \
  fv-apalache "$G/lease-induction/Lease.tla"
t "lease-induction: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/lease-induction/Lease.mutations"

t "bad/non-inductive-invariant: WeakInv holds on the bounded TLC run" 0 'PASS Bounded.cfg: holds' \
  fv-tlc "$B/non-inductive-invariant/Lease.tla" "$B/non-inductive-invariant/Bounded.cfg"
t "bad/non-inductive-invariant: the same invariant fails Apalache's inductive step, which is the symptom" 1 'FAIL Step.icfg: expected holds, got violated WeakInv' \
  fv-apalache "$B/non-inductive-invariant/Lease.tla" "$B/non-inductive-invariant/Step.icfg"

# Invariants of the fv-apalache wrapper itself, not of an example.
t "fv-apalache exits 3 when Apalache is not installed" 3 '^UNAVAILABLE apalache' \
  env FV_HOME="$(mktemp -d)" fv-apalache "$G/lease-induction/Lease.tla"
AP_BAD="$(mktemp -d)"
printf -- '---- MODULE Broken ----\nVARIABLE x\nInit == x = \n====\n' > "$AP_BAD/Broken.tla"
printf '%s\n' '\* expect: violated Inv' 'INIT Init' 'INV Inv' > "$AP_BAD/Check.icfg"
t "fv-apalache reports a broken spec as an error, never as the violation a check expects" 1 '^ERROR Check.icfg' \
  fv-apalache "$AP_BAD/Broken.tla"
