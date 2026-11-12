#!/usr/bin/env bash
# Run with: bash tests/test_structure.sh
# These are invariants of how the plugin's text is organised. Every file that a
# skill or a reference tells Claude to read must exist.
set -uo pipefail

P="$(cd "$(dirname "$0")/.." && pwd)/plugins/fv-toolkit"
fail=0
check() { if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi; }

skills="$(find "$P/skills" -name SKILL.md 2>/dev/null)"
check "the plugin ships at least one skill" '[ -n "$skills" ]'

# Paths written as ${CLAUDE_PLUGIN_ROOT}/... in any markdown file of the plugin.
missing="$(grep -rhoE --include='*.md' '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./-]+' "$P" 2>/dev/null |
  sed 's|\${CLAUDE_PLUGIN_ROOT}/||; s|[.]$||' | sort -u |
  while read -r rel; do [ -e "$P/$rel" ] || printf '%s ' "$rel"; done)"
check "every \${CLAUDE_PLUGIN_ROOT} path exists${missing:+ (missing: $missing)}" '[ -z "$missing" ]'

# Relative markdown links. A link with a scheme holds a colon and is skipped.
broken="$(find "$P" -name '*.md' 2>/dev/null | while read -r file; do
  grep -oE '\]\([^)#: ]+(#[^)]*)?\)' "$file" | sed -E 's/^\]\(([^)#]+).*$/\1/' |
    while read -r rel; do [ -e "$(dirname "$file")/$rel" ] || printf '%s->%s ' "${file#"$P"/}" "$rel"; done
done)"
check "every relative link resolves${broken:+ (broken: $broken)}" '[ -z "$broken" ]'

exit $fail
