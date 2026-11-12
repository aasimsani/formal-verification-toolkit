#!/usr/bin/env bash
# Run with: bash tests/test_examples.sh
# Invariants of the shipped examples. A good example meets its declared
# outcomes and detects its mutations. A bad example produces the symptom that
# its README states. Run plugins/fv-toolkit/scripts/fv-install once first.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
S="$ROOT/plugins/fv-toolkit/scripts"
K="$ROOT/plugins/fv-toolkit/skills"
export PATH="$S:$PATH"
fail=0

# t <name> <wanted exit code> <regex the output must match> <command...>
t() {
  local name=$1 want=$2 pat=$3 out rc
  shift 3
  out="$("$@" 2>&1)"
  rc=$?
  if [ "$rc" = "$want" ] && echo "$out" | grep -qE -- "$pat"; then
    echo "ok   - $name"
  else
    echo "FAIL - $name (exit $rc, wanted $want and /$pat/)"
    echo "$out" | tail -8 | sed 's/^/       /'
    fail=1
  fi
}

# --- fv-tlaplus ------------------------------------------------------------
G="$K/fv-tlaplus/examples/good"
B="$K/fv-tlaplus/examples/bad"

t "refund-race: every config meets its declared outcome" 0 'PASS CheckThenRefund.cfg: violated NeverOverRefund' \
  fv-tlc "$G/refund-race/RefundRace.tla"
t "refund-race: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/refund-race/RefundRace.mutations"

t "idempotent-receiver: every config meets its declared outcome" 0 'PASS EffectThenRecord.cfg: violated AtMostOnce' \
  fv-tlc "$G/idempotent-receiver/IdempotentReceiver.tla"
t "idempotent-receiver: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/idempotent-receiver/IdempotentReceiver.mutations"

t "bad/merged-atomicity: the merged model passes, which is the symptom" 0 'PASS Merged.cfg: holds' \
  fv-tlc "$B/merged-atomicity/MergedRefund.tla"
t "bad/liveness-without-fairness: TLC answers with a stuttering counterexample" 0 'PASS NoFairness.cfg: liveness' \
  fv-tlc "$B/liveness-without-fairness/Worker.tla"
t "bad/unreachable-state: the invariant holds and only the witness exposes it" 1 'FAIL Witness.cfg: expected violated NeverCommitted, got holds' \
  fv-tlc "$B/unreachable-state/Commit.tla"

# --- fv-hypothesis ---------------------------------------------------------
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

exit $fail
