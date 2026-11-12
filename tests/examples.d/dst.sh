# needs: fv-install --check dst
# Example checks for the fv-dst skill. tests/test_examples.sh sources this file.

D="$K/fv-dst/examples"

t "primary-backup: the chosen design holds across the sweep" 0 "PASS sweep NeverAckedWriteLost: holds for 500 seeds" \
  python3 "$D/good/primary-backup/simulate.py" --policy commit-after-replicate --sweep 500
t "primary-backup: the rejected design loses an acked write, which is the witness" 1 "FAIL sweep NeverAckedWriteLost" \
  python3 "$D/good/primary-backup/simulate.py" --policy ack-then-replicate --sweep 500
t "primary-backup: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$D/good/primary-backup/simulate.mutations"
t "bad/unseeded-rng: the reported failing seed does not replay on its own, which is the symptom" 0 "PASS replay NeverAckedWriteLost: holds" \
  python3 "$D/bad/unseeded-rng/sim_unseeded.py" --replay 5
t "bad/fault-never-injected: the rejected design passes because the fault never fires, which is the symptom" 0 "PASS sweep NeverAckedWriteLost: holds for 500 seeds" \
  python3 "$D/bad/fault-never-injected/sim_no_fault.py" --sweep 500
