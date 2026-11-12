# needs: fv-install --check sqlequiv
# Example checks for the fv-sqlequiv skill. tests/test_examples.sh sources this file.

V="$K/fv-sqlequiv/examples"

t "rewrite-equivalence: the equivalent rewrite holds on every generated table" 0 "PASS check DistinctEqualsGroupBy: equivalent on 13 tables" \
  fv-sqlequiv "$V/good/rewrite-equivalence/rewrites.sql"
t "rewrite-equivalence: the rejected rewrite finds the witness table" 0 "PASS check NotInEqualsNotExists: different" \
  fv-sqlequiv "$V/good/rewrite-equivalence/rewrites.sql"
t "rewrite-equivalence: every planted bug is detected" 0 "uncovered=0" \
  fv-mutate "$V/good/rewrite-equivalence/rewrites.mutations"
t "bad/domain-without-null: the NULL-sensitive rewrite is reported equivalent, which is the symptom" 0 "PASS check NotInEqualsNotExists: equivalent on 49 tables" \
  python3 "$V/bad/domain-without-null/check_without_null.py"
t "bad/domain-without-duplicates: the duplicate-sensitive rewrite is reported equivalent, which is the symptom" 0 "PASS check XEqualsDistinctX: equivalent on 3 tables" \
  python3 "$V/bad/domain-without-duplicates/check_without_duplicates.py"

# Invariants of the fv-sqlequiv wrapper itself: a broken artifact reports
# ERROR, and a missing sqlite3 module exits 3.
T_SQLEQUIV="$(mktemp -d)"
printf -- '-- check: Broken\n-- schema\nCREATE TABLE t (x INTEGER)\n-- query_a\nSELECT * FROM nosuchtable;\n-- query_b\nSELECT * FROM t;\n' > "$T_SQLEQUIV/broken.sql"
t "fv-sqlequiv reports ERROR for a query against a table the schema never declares" 1 "^ERROR Broken: no such table" \
  fv-sqlequiv "$T_SQLEQUIV/broken.sql"
mkdir -p "$T_SQLEQUIV/no-sqlite3" && printf 'raise ImportError("no sqlite3 for this test")\n' > "$T_SQLEQUIV/no-sqlite3/sqlite3.py"
t "fv-sqlequiv exits 3 when this Python has no sqlite3 module" 3 "^UNAVAILABLE sqlequiv" \
  env PYTHONPATH="$T_SQLEQUIV/no-sqlite3" fv-sqlequiv "$V/good/rewrite-equivalence/rewrites.sql"
rm -rf "$T_SQLEQUIV"
