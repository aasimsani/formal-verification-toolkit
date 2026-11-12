# needs: fv-install --check cedar
# Example checks for the fv-cedar skill. tests/test_examples.sh sources this
# file.
H="$K/fv-cedar/examples"
G="$H/good"
B="$H/bad"

t "document-access: every entity meets its declared decision" 0 'PASS test bob_allowed_secret_high_clearance: ok' \
  fv-cedar "$G/document-access/policy.cedar" "$G/document-access/schema.cedarschema" "$G/document-access/tests.json"
t "document-access: the rejected design widens access, which fv-cedar must catch" 1 'FAIL test alice_denied_secret_low_clearance: expected Deny, got Allow' \
  fv-cedar "$G/document-access/DropClearanceCheck.cedar" "$G/document-access/schema.cedarschema" "$G/document-access/tests.json"
t "document-access: every planted bug is detected" 0 'uncovered=0' \
  fv-mutate "$G/document-access/document-access.mutations"

t "bad/shadowed-permit: the weak test suite passes, which is the symptom" 0 'PASS test alice_denied_secret_low_clearance: ok' \
  fv-cedar "$B/shadowed-permit/policy.cedar" "$B/shadowed-permit/schema.cedarschema" "$B/shadowed-permit/tests.json"

# Invariants of the fv-cedar wrapper itself, not of an example.
broken="$(mktemp -t fv-cedar-broken.XXXXXX)"
printf 'permit(principal, action, resource) when { not valid cedar !!! ' > "$broken"
t "fv-cedar reports ERROR for a policy set that fails to parse" 1 '^ERROR tests.json:' \
  fv-cedar "$broken" "$G/document-access/schema.cedarschema" "$G/document-access/tests.json"
rm -f "$broken"
t "fv-cedar exits 3 when the cedar binary is missing" 3 '^UNAVAILABLE cedar' \
  env FV_HOME="$(mktemp -d)" fv-cedar "$G/document-access/policy.cedar" "$G/document-access/schema.cedarschema" "$G/document-access/tests.json"
