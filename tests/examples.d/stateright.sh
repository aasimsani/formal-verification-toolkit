# needs: fv-install --check stateright
# Example checks for the fv-stateright skill. tests/test_examples.sh sources
# this file. CARGO_TARGET_DIR moves build output outside each crate so
# fv-mutate's copy stays small and the compiled tests are reused between runs.
H="$K/fv-stateright/examples"
G="$H/good"
B="$H/bad"
T="${FV_HOME:-$HOME/.cache/fv}/stateright/target"

t "two-phase-commit: both designs meet their declared outcome" 0 'test result: ok' \
  sh -c "cd '$G/two-phase-commit' && export CARGO_TARGET_DIR='$T/two-phase-commit' && cargo test --quiet --lib"
t "two-phase-commit: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/two-phase-commit/two-phase-commit.mutations"

t "bad/narrow-actions: the vacuous check passes, which is the symptom" 0 'test result: ok' \
  sh -c "cd '$B/narrow-actions' && export CARGO_TARGET_DIR='$T/narrow-actions' && cargo test --quiet --lib"
