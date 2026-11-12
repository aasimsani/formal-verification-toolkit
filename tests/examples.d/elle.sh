# needs: fv-install --check elle
# Example checks for the fv-elle skill. tests/test_examples.sh sources this file.

G="$K/fv-elle/examples/good"
B="$K/fv-elle/examples/bad"

t "list-append-serializable: the clean history checks out" 0 'PASS History.edn: valid' \
  fv-elle "$G/list-append-serializable/History.edn"
t "list-append-serializable: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/list-append-serializable/History.mutations"

t "write-skew: the declared anomaly is found" 0 'PASS History.edn: invalid G2-item' \
  fv-elle "$G/write-skew/History.edn"
t "write-skew: every planted fix is detected" 0 'uncovered=0' \
  fv-mutate "$G/write-skew/History.mutations"

t "bad/weak-model: the write skew passes under a narrower anomaly list, which is the symptom" 0 'PASS History.edn: valid' \
  fv-elle "$B/weak-model/History.edn"
t "bad/predicate-anomaly: the history passes cleanly, which is the symptom" 0 'PASS History.edn: valid' \
  fv-elle "$B/predicate-anomaly/History.edn"
