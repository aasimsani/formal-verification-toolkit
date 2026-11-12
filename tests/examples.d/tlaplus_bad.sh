# needs: fv-install --check tla
# Anti-pattern examples for the fv-tlaplus skill. tests/test_examples.sh
# sources this file. It is separate from tests/examples.d/tlaplus.sh, which
# another track owns.

B="$K/fv-tlaplus/examples/bad"

t "strong-fairness-everywhere: weak fairness on every action misses the liveness violation" 0 'PASS WeaklyFair.cfg: liveness' \
  fv-tlc "$B/strong-fairness-everywhere/TurnBasedWorker.tla" "$B/strong-fairness-everywhere/WeaklyFair.cfg"
t "strong-fairness-everywhere: strong fairness on the one action that needs it closes the gap" 0 'PASS StronglyFair.cfg: holds' \
  fv-tlc "$B/strong-fairness-everywhere/TurnBasedWorker.tla" "$B/strong-fairness-everywhere/StronglyFair.cfg"

t "vacuous-fairness: the guard the fairness condition depends on is unreachable" 0 'PASS NeverStuck.cfg: holds' \
  fv-tlc "$B/vacuous-fairness/Watchdog.tla" "$B/vacuous-fairness/NeverStuck.cfg"
t "vacuous-fairness: the property holds the same with the vacuous fairness condition removed" 0 'PASS WithoutEscalateFairness.cfg: holds' \
  fv-tlc "$B/vacuous-fairness/Watchdog.tla" "$B/vacuous-fairness/WithoutEscalateFairness.cfg"

t "symmetry-with-liveness: without symmetry TLC finds the real starvation" 0 'PASS NoSymmetry.cfg: liveness' \
  fv-tlc "$B/symmetry-with-liveness/TokenPassing.tla" "$B/symmetry-with-liveness/NoSymmetry.cfg"
t "symmetry-with-liveness: with symmetry TLC reports a counterexample that violates the spec's own fairness" 0 'PASS WithSymmetry.cfg: liveness' \
  fv-tlc "$B/symmetry-with-liveness/TokenPassing.tla" "$B/symmetry-with-liveness/WithSymmetry.cfg"

t "unbounded-state: the bounded version finishes and holds" 0 'PASS Bounded.cfg: holds' \
  fv-tlc "$B/unbounded-state/UnboundedCounter.tla" "$B/unbounded-state/Bounded.cfg"

# The unbounded config's state space is infinite, so fv-tlc never returns.
# A short-lived background check confirms it is still running instead of
# waiting on a result that never comes.
name="unbounded-state: the unbounded config has not finished after 5s, which is the symptom"
fv-tlc "$B/unbounded-state/UnboundedCounter.tla" "$B/unbounded-state/Unbounded.cfg" >/dev/null 2>&1 &
pid=$!
disown "$pid" 2>/dev/null
sleep 5
if kill -0 "$pid" 2>/dev/null; then
  echo "ok   - $name"
else
  echo "FAIL - $name (the unbounded config finished within 5s)"
  fail=1
fi
pkill -P "$pid" 2>/dev/null
kill "$pid" 2>/dev/null
wait "$pid" 2>/dev/null

t "invariants-only: the invariant holds while a forbidden step still happens" 0 'PASS InvariantOnly.cfg: holds' \
  fv-tlc "$B/invariants-only/MonotonicCounter.tla" "$B/invariants-only/InvariantOnly.cfg"
t "invariants-only: the action property catches the forbidden step" 0 'PASS ActionProperty.cfg: liveness' \
  fv-tlc "$B/invariants-only/MonotonicCounter.tla" "$B/invariants-only/ActionProperty.cfg"
