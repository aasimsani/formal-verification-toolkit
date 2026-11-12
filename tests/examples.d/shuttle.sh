# needs: fv-install --check shuttle
# Example checks for the fv-shuttle skill. tests/test_examples.sh sources this
# file. CARGO_TARGET_DIR moves build output outside each crate so fv-mutate's
# copy stays small and the compiled tests are reused between runs.
H="$K/fv-shuttle/examples"
G="$H/good"
B="$H/bad"
T="${FV_HOME:-$HOME/.cache/fv}/shuttle/target"

t "counter: both schedulers confirm the property" 0 'test result: ok' \
  sh -c "cd '$G/counter' && export CARGO_TARGET_DIR='$T/counter' && RUSTFLAGS='--cfg shuttle' cargo test --quiet --lib && RUSTFLAGS='--cfg loom' cargo test --quiet --lib"
t "counter: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/counter/counter.mutations"

t "bad/plain-threads: the racy check passes, which is the symptom" 0 'test result: ok' \
  sh -c "cd '$B/plain-threads' && export CARGO_TARGET_DIR='$T/plain-threads' && cargo test --quiet --lib"
t "bad/narrow-loom: the narrowed check passes, which is the symptom" 0 'test result: ok' \
  sh -c "cd '$B/narrow-loom' && export CARGO_TARGET_DIR='$T/narrow-loom' && RUSTFLAGS='--cfg loom' cargo test --quiet --lib"
