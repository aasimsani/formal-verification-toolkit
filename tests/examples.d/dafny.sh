# needs: fv-install --check dafny
# Example checks for the fv-dafny skill. tests/test_examples.sh sources this file.

G="$K/fv-dafny/examples/good"
B="$K/fv-dafny/examples/bad"
py() { uv run --quiet --with hypothesis --with pytest "$@"; }

t "allocation: the proof verifies" 0 'PASS Allocate.dcfg: verified' \
  fv-dafny "$G/allocation/Allocate.dfy"
t "allocation: every planted bug is detected" 0 'uncovered=0' \
  py fv-mutate "$G/allocation/Allocate.mutations"

t "bad/unsound-proof: assume false verifies, which is the symptom" 0 'PASS AssumeFalse.dcfg: unsound' \
  fv-dafny "$B/unsound-proof/AssumeFalse.dfy" "$B/unsound-proof/AssumeFalse.dcfg"
t "bad/unsound-proof: a contradictory precondition verifies with no warning, which is the symptom" 0 'PASS ContradictoryPrecondition.dcfg: verified' \
  fv-dafny "$B/unsound-proof/ContradictoryPrecondition.dfy" "$B/unsound-proof/ContradictoryPrecondition.dcfg"

t "bad/masked-timeout: the proof times out at a tight limit" 0 'PASS Tight.dcfg: failed' \
  fv-dafny "$B/masked-timeout/Slow.dfy" "$B/masked-timeout/Tight.dcfg"
t "bad/masked-timeout: raising the limit alone makes it verify, which is the symptom" 0 'PASS Relaxed.dcfg: verified' \
  fv-dafny "$B/masked-timeout/Slow.dfy" "$B/masked-timeout/Relaxed.dcfg"

# Invariants of the fv-dafny wrapper itself, not of an example.
t "fv-dafny exits 3 when Dafny is not installed" 3 '^UNAVAILABLE dafny' \
  env FV_HOME="$(mktemp -d)" fv-dafny "$G/allocation/Allocate.dfy"
DF_BAD="$(mktemp -d)"
printf 'method Broken( {\n' > "$DF_BAD/Broken.dfy"
printf '%s\n' '\* expect: failed' > "$DF_BAD/Broken.dcfg"
t "fv-dafny reports a file that does not parse as an error, never as the failure a check expects" 1 '^ERROR Broken.dcfg' \
  fv-dafny "$DF_BAD/Broken.dfy"
