#!/usr/bin/env bash
# Seeds the workspace for this case. `claude plugin eval --scaffold` runs it outside the sandbox.
set -euo pipefail
git init -q -b main .
git config user.email dev@example.com
git config user.name Dev
mkdir -p reports

cat > CLAUDE.md <<'MD'
# Finance reports

`reports/` holds the SQL behind the finance reports. The warehouse runs SQLite-compatible SQL.

## Tools on this machine
- This machine has no network access.
- `python3` is installed with its standard library, which includes `sqlite3`. Nothing else needs to be installed.
MD

cat > reports/schema.sql <<'SQL'
-- state is 1 for a settled payment and 2 for a failed one.
CREATE TABLE invoices (id INTEGER);
CREATE TABLE payments (invoice_id INTEGER, state INTEGER);
SQL

cat > reports/unpaid_old.sql <<'SQL'
-- Invoices with a settled payment, and invoices with no payment at all.
SELECT i.id
FROM invoices i
LEFT JOIN payments p ON p.invoice_id = i.id
WHERE p.state = 1 OR p.state IS NULL;
SQL

cat > reports/unpaid_new.sql <<'SQL'
-- Same report, with the filter moved into the join.
SELECT i.id
FROM invoices i
LEFT JOIN payments p ON p.invoice_id = i.id AND p.state = 1;
SQL
git add -A && git commit -qm "finance reports"
