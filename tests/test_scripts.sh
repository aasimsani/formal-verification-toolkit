#!/usr/bin/env bash
# Run with: bash tests/test_scripts.sh
# These are invariants of the checker wrappers. The tests run the real TLC and
# Alloy jars, so run plugins/fv-toolkit/scripts/fv-install once before them.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
S="$ROOT/plugins/fv-toolkit/scripts"
F="$ROOT/tests/fixtures"
export PATH="$S:$PATH"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
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
copy() { rm -rf "$T/$2" && cp -R "$F/$1" "$T/$2"; }
tree_sum() { (cd "$F" && find . -type f | sort | xargs shasum -a 256 | shasum -a 256); }
before="$(tree_sum)"

# --- fv-install ------------------------------------------------------------
echo "not a jar" > "$T/bogus.jar"
t "fv-install rejects a download whose checksum differs" 3 '^UNAVAILABLE tla: checksum' \
  env FV_HOME="$T/home" FV_TLA_URL="file://$T/bogus.jar" fv-install tla
t "fv-install leaves no jar behind after a rejected download" 0 '^0$' \
  sh -c "find '$T/home' -name '*.jar*' 2>/dev/null | wc -l | tr -d ' '"

# On-demand tools: fv-install hands any other name to scripts/installers/<name>.
mkdir -p "$T/inst"
printf "#!/usr/bin/env bash\n[ \"\${1:-}\" = --check ] && { echo \"UNAVAILABLE good: not installed\"; exit 3; }\necho \"READY good /opt/good\"\n" > "$T/inst/good"
printf "#!/usr/bin/env bash\necho \"UNAVAILABLE bad: the download failed\"\nexit 3\n" > "$T/inst/bad"
chmod +x "$T/inst/good" "$T/inst/bad"
t "fv-install runs the installer of an on-demand tool" 0 "^READY good /opt/good" \
  env FV_INSTALLERS="$T/inst" fv-install good
t "fv-install never reports READY for an on-demand tool whose installer failed" 3 "^UNAVAILABLE bad" \
  env FV_INSTALLERS="$T/inst" fv-install bad
t "fv-install --check asks an installer for its state and installs nothing" 3 "^UNAVAILABLE good: not installed" \
  env FV_INSTALLERS="$T/inst" fv-install --check good
t "fv-install --check does not download a missing core jar" 3 "^UNAVAILABLE tla" \
  env FV_HOME="$T/nohome" fv-install --check tla
t "fv-install --check leaves no file behind" 0 "^0$" \
  sh -c "find \"$T/nohome\" -type f 2>/dev/null | wc -l | tr -d \" \""
t "fv-install rejects a name that has no installer" 2 "usage" \
  env FV_INSTALLERS="$T/inst" fv-install nosuchtool
t "fv-install --list names the core tools and the on-demand tools" 0 "^good$" \
  env FV_INSTALLERS="$T/inst" fv-install --list

# The example runner must not pass by skipping when a tool is required.
t "test_examples skips a tool that is not installed" 0 "^skip - tlaplus" \
  env FV_HOME="$T/nohome" bash "$ROOT/tests/test_examples.sh" tlaplus
t "test_examples fails a missing tool when FV_REQUIRE=1" 1 "^FAIL - tlaplus" \
  env FV_HOME="$T/nohome" FV_REQUIRE=1 bash "$ROOT/tests/test_examples.sh" tlaplus

# --- fv-tlc ----------------------------------------------------------------
t "fv-tlc passes when every config matches its expect header" 0 'PASS Witness.cfg: violated NeverMax' \
  fv-tlc "$F/tla/Counter.tla"

copy tla wrong
printf '\\* expect: violated Bounded\nSPECIFICATION Spec\nCONSTANT Max = 3\nINVARIANT Bounded\nCHECK_DEADLOCK FALSE\n' > "$T/wrong/Holds.cfg"
t "fv-tlc fails a config whose outcome differs from its header" 1 'FAIL Holds.cfg: expected violated Bounded, got holds' \
  fv-tlc "$T/wrong/Counter.tla" "$T/wrong/Holds.cfg"

copy tla nohdr
printf 'SPECIFICATION Spec\nCONSTANT Max = 3\nINVARIANT Bounded\nCHECK_DEADLOCK FALSE\n' > "$T/nohdr/Holds.cfg"
t "fv-tlc fails a config that has no expect header" 1 'FAIL Holds.cfg: no expect header' \
  fv-tlc "$T/nohdr/Counter.tla" "$T/nohdr/Holds.cfg"

copy tla broken
sed -i.bak 's/^Init == x = 0$/Init == x = /' "$T/broken/Counter.tla"
t "fv-tlc reports a parse error as an error when the header expects a violation" 1 '^ERROR Witness.cfg' \
  fv-tlc "$T/broken/Counter.tla" "$T/broken/Witness.cfg"

t "fv-tlc exits 3 when the jar is missing" 3 '^UNAVAILABLE tla' \
  env FV_HOME="$T/empty" fv-tlc "$F/tla/Counter.tla"

copy tla trace
printf '\\* expect: holds\nSPECIFICATION Spec\nCONSTANT Max = 3\nINVARIANT NeverMax\nCHECK_DEADLOCK FALSE\n' > "$T/trace/Holds.cfg"
t "fv-tlc prints the step that broke an invariant as changed variables" 1 'Next: x: 2 -> 3' \
  fv-tlc "$T/trace/Counter.tla" "$T/trace/Holds.cfg"

t "fv-tlc reduces a function-valued variable to the keys that changed" 0 'Start: pc\[[ab]\]: "idle" -> "busy"' \
  fv-tlc --trace "$F/tla-pair/Pair.tla"
t "fv-tlc --json prints each state of a counterexample as parsed values" 0 '^busy busy 2 2$' \
  sh -c "fv-tlc --json '$F/tla-pair/Pair.tla' | python3 -c 'import json,sys; r=json.load(sys.stdin)[0]; s=r[\"trace\"][-1][\"state\"]; print(s[\"pc\"][\"a\"], s[\"pc\"][\"b\"], len(s[\"log\"]), s[\"log\"][1][\"n\"])'"
t "fv-tlc --json keeps the verdict and the exit code of the plain run" 1 '"verdict": "FAIL"' \
  fv-tlc --json "$T/trace/Counter.tla" "$T/trace/Holds.cfg"

# --- fv-alloy --------------------------------------------------------------
t "fv-alloy passes when every command matches its expectation" 0 'PASS check AtMostOneNext: UNSAT' \
  fv-alloy "$F/als/Small.als"

copy als sat
sed -i.bak 's/^check NoSelfLoop for 3 expect 1$/check NoSelfLoop for 3/' "$T/sat/Small.als"
t "fv-alloy fails a check that finds a counterexample" 1 'FAIL check NoSelfLoop: expected UNSAT, got SAT' \
  fv-alloy "$T/sat/Small.als"

copy als unsat
echo 'fact { no link }' >> "$T/unsat/Small.als"
t "fv-alloy fails a run that finds no instance" 1 'FAIL run hasEdge: expected SAT, got UNSAT' \
  fv-alloy "$T/unsat/Small.als"

copy als norun
sed -i.bak '/^run hasEdge/d' "$T/norun/Small.als"
t "fv-alloy fails a model that has checks and no run" 1 'FAIL .*no run command' \
  fv-alloy "$T/norun/Small.als"

t "fv-alloy exits 3 when the jar is missing" 3 '^UNAVAILABLE alloy' \
  env FV_HOME="$T/empty" fv-alloy "$F/als/Small.als"

# --- fv-mutate -------------------------------------------------------------
t "fv-mutate detects each planted bug and keeps the harmless edit green" 0 'DETECTED the counter stops one short' \
  fv-mutate "$F/tla/Counter.mutations"
t "fv-mutate reports the harmless edit as GREEN" 0 '^GREEN a comment on Init' \
  fv-mutate "$F/tla/Counter.mutations"
t "fv-mutate detects a planted bug in an Alloy model" 0 'DETECTED a node may have many successors' \
  fv-mutate "$F/als/Small.mutations"

mut() { # mut <dir> <body>: write a mutations file into a copy of the TLA+ fixture
  copy tla "$1"
  printf 'run fv-tlc Counter.tla Holds.cfg Witness.cfg LiveFair.cfg\nfile Counter.tla\n%s\n' "$2" > "$T/$1/Counter.mutations"
}
mut missed 'mutation the property is weakened
detects Bounded
- Bounded == x <= Max
+ Bounded == x <= Max + 1'
t "fv-mutate reports MISSED when the check stays green" 1 '^MISSED the property is weakened' \
  fv-mutate "$T/missed/Counter.mutations"

mut error 'mutation the edit breaks the syntax
detects Bounded
- Init == x = 0
+ Init == x ='
t "fv-mutate reports ERROR when the check fails for another reason" 1 '^ERROR the edit breaks the syntax' \
  fv-mutate "$T/error/Counter.mutations"

mut absent 'mutation the text is not in the file
detects Bounded
- Init == x = 7
+ Init == x = 8'
t "fv-mutate reports ERROR when the text to replace does not occur once" 1 '^ERROR the text is not in the file: .*occurs 0 times' \
  fv-mutate "$T/absent/Counter.mutations"

mut uncovered 'properties Bounded ReachesMax
mutation the increment ignores the bound
detects Bounded
- Next == x < Max /\ x'"'"' = x + 1
+ Next == x <= Max /\ x'"'"' = x + 1'
t "fv-mutate reports UNCOVERED for a property that no mutation targets" 1 '^UNCOVERED ReachesMax' \
  fv-mutate "$T/uncovered/Counter.mutations"

mut brittle 'harmless this edit is not harmless
- Next == x < Max /\ x'"'"' = x + 1
+ Next == x <= Max /\ x'"'"' = x + 1'
t "fv-mutate reports BRITTLE when a harmless edit turns the check red" 1 '^BRITTLE this edit is not harmless' \
  fv-mutate "$T/brittle/Counter.mutations"

copy tla baseline
printf 'run fv-tlc Counter.tla Deadlock.cfg Missing.cfg\nfile Counter.tla\n' > "$T/baseline/Counter.mutations"
t "fv-mutate refuses to run when the unmutated check fails" 1 '^BASELINE FAILED' \
  fv-mutate "$T/baseline/Counter.mutations"

t "the scripts leave the fixture files unchanged" 0 '^same$' \
  sh -c "[ '$before' = '$(tree_sum)' ] && echo same"

# --- fv-drift --------------------------------------------------------------
R="$T/repo"
mkdir -p "$R/src" "$R/model"
git -C "$R" init -q -b main
git -C "$R" config user.email test@example.com
git -C "$R" config user.name test
echo 'def refund(): pass' > "$R/src/app.py"
git -C "$R" add -A && git -C "$R" commit -qm "add app"
sha="$(git -C "$R" rev-parse --short HEAD)"
printf -- '---- MODULE M ----\n\\* Source read at: %s\n\\* Covers: src/app.py\n====\n' "$sha" > "$R/model/M.tla"
printf -- '---- MODULE N ----\n====\n' > "$R/model/N.tla"
git -C "$R" add -A && git -C "$R" commit -qm "add models"
t "fv-drift reports IN SYNC when no commit touched the covered code" 0 '^IN SYNC .*M.tla' \
  fv-drift "$R/model/M.tla"
t "fv-drift reports NO RECORD for a model without a sync header" 1 '^NO RECORD .*N.tla' \
  fv-drift "$R/model/N.tla"
echo 'def refund(): return 1' > "$R/src/app.py"
git -C "$R" commit -qam "change refund"
t "fv-drift reports CHANGED after a commit to the covered code" 1 '^CHANGED .*M.tla: 1 commit' \
  fv-drift "$R/model"

exit $fail
