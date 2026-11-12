#!/usr/bin/env bash
# Run with: bash tests/test_examples.sh [tool ...]
#
# Invariants of the shipped examples. A good example meets its declared
# outcomes and detects its mutations. A bad example produces the symptom that
# its README states.
#
# Each tool has one file, tests/examples.d/<tool>.sh. With no argument, every
# file runs. A file starts with "# needs: <command>". When that command fails,
# the tool is not installed and the file is skipped. FV_REQUIRE=1 turns a skip
# into a failure, so CI cannot pass by skipping.
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
    echo "$out" | tail -8 | sed "s/^/       /"
    fail=1
  fi
}

if [ $# -eq 0 ]; then
  set -- $(cd "$ROOT/tests/examples.d" && ls *.sh | sed "s/\.sh$//")
fi

for tool in "$@"; do
  file="$ROOT/tests/examples.d/$tool.sh"
  if [ ! -f "$file" ]; then
    echo "FAIL - $tool: tests/examples.d/$tool.sh does not exist"
    fail=1
    continue
  fi
  needs="$(sed -n "s/^# needs: //p" "$file" | head -1)"
  if [ -n "$needs" ] && ! bash -c "$needs" >/dev/null 2>&1; then
    if [ "${FV_REQUIRE:-0}" = 1 ]; then
      echo "FAIL - $tool: \"$needs\" failed and FV_REQUIRE=1"
      fail=1
    else
      echo "skip - $tool: \"$needs\" failed"
    fi
    continue
  fi
  . "$file"
done

exit $fail
