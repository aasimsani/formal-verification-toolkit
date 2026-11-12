#!/usr/bin/env bash
# Seeds the workspace for this case. `claude plugin eval --scaffold` runs it outside the sandbox.
set -euo pipefail
git init -q -b main .
git config user.email dev@example.com
git config user.name Dev
mkdir -p billing tests
printf '.venv/\n__pycache__/\n.hypothesis/\n' > .gitignore

# The run's shell has no network, so the test tools are installed here.
uv venv --quiet .venv
uv pip install --quiet --python .venv/bin/python hypothesis pytest

cat > CLAUDE.md <<'MD'
# Billing periods

`billing/ranges.py` merges the billing periods of a customer.

## Tools on this machine
- This machine has no network access.
- Hypothesis and pytest are already installed in `.venv/`. Run tests with `.venv/bin/python -m pytest`.
MD

: > billing/__init__.py
cat > billing/ranges.py <<'PY'
"""Billing periods as (start, end) pairs of dates, both inclusive."""
from datetime import date


def merge(ranges: list[tuple[date, date]]) -> list[tuple[date, date]]:
    """Merge billing periods that overlap.

    The result covers exactly the days that the input covers.
    No two periods in the result overlap.
    The result is sorted by start date.
    Every input period has start <= end.
    """
    out = []
    for start, end in sorted(ranges):
        if out and start <= out[-1][1]:
            out[-1] = (out[-1][0], end)
        else:
            out.append((start, end))
    return out
PY
git add -A && git commit -qm "billing periods"
