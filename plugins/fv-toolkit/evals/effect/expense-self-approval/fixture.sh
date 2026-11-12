#!/usr/bin/env bash
# Seeds the workspace for this case. `claude plugin eval --scaffold` runs it outside the sandbox.
set -euo pipefail
git init -q -b main .
git config user.email dev@example.com
git config user.name Dev
mkdir -p policy
echo ".fv/" > .gitignore
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../_lib/checkers.sh"
install_checkers alloy

{
  cat <<'MD'
# Expense approvals

`policy/approvals.py` decides who may approve an expense.
MD
  checkers_note
} > CLAUDE.md

cat > policy/org.yaml <<'YAML'
# manager: who a person reports to. deputy: who may approve on a person's behalf.
people:
  dana:  { manager: erin }
  erin:  { manager: farid, deputy: dana }
  farid: { manager: null }
YAML

cat > policy/approvals.py <<'PY'
"""Who may approve an expense."""


def acting_for(org, person):
    """Return the person and everyone who acts on their behalf, through any chain of deputies."""
    seen, todo = set(), [person]
    while todo:
        current = todo.pop()
        if current in seen:
            continue
        seen.add(current)
        deputy = org[current].get("deputy")
        if deputy:
            todo.append(deputy)
    return seen


def can_approve(org, approver, requester):
    """An expense is approved by the requester's manager, or by anyone who acts for that manager."""
    manager = org[requester].get("manager")
    return manager is not None and approver in acting_for(org, manager)
PY
git add -A && git commit -qm "expense approvals"
