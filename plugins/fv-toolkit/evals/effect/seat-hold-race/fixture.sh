#!/usr/bin/env bash
# Seeds the workspace for this case. `claude plugin eval --scaffold` runs it outside the sandbox.
set -euo pipefail
git init -q -b main .
git config user.email dev@example.com
git config user.name Dev
mkdir -p ticketing
echo ".fv/" > .gitignore
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../_lib/checkers.sh"
install_checkers tla

{
  cat <<'MD'
# Ticketing service

Sells seats for events. `ticketing/holds.py` holds a seat for a buyer while they pay.
MD
  checkers_note
} > CLAUDE.md

cat > ticketing/holds.py <<'PY'
"""Seat holds. The `seats` table has one row per seat."""

HOLD_SECONDS = 600


def hold_seat(db, seat_id, buyer_id, now):
    """Hold a seat for a buyer while they pay. Return True when the buyer now holds it."""
    seat = db.fetch_one("SELECT status, held_until FROM seats WHERE id = %s", seat_id)
    if seat.status == "sold":
        return False
    if seat.status == "held" and seat.held_until > now:
        return False
    db.execute(
        "UPDATE seats SET status = 'held', held_by = %s, held_until = %s WHERE id = %s",
        buyer_id, now + HOLD_SECONDS, seat_id,
    )
    return True


def confirm_payment(db, seat_id, buyer_id):
    """Called by the payment provider after the buyer paid."""
    seat = db.fetch_one("SELECT held_by FROM seats WHERE id = %s", seat_id)
    if seat.held_by != buyer_id:
        return False
    db.execute("UPDATE seats SET status = 'sold', sold_to = %s WHERE id = %s", buyer_id, seat_id)
    return True


def release_expired(db, now):
    """Runs every minute and frees the holds that ran out."""
    db.execute(
        "UPDATE seats SET status = 'free', held_by = NULL WHERE status = 'held' AND held_until <= %s",
        now,
    )
PY
git add -A && git commit -qm "ticketing holds"
