---
description: Two requests race through a read and a later write.
tags: [route, tlaplus]
max_turns: 16
timeout_seconds: 360
allowed_tools: [Read, Glob, Grep, Skill]
---

Our ticketing service holds a seat like this:

```python
def hold_seat(db, seat_id, buyer_id, now):
    seat = db.fetch_one("SELECT status, held_until FROM seats WHERE id = %s", seat_id)
    if seat.status == "sold" or (seat.status == "held" and seat.held_until > now):
        return False
    db.execute("UPDATE seats SET status = 'held', held_by = %s, held_until = %s WHERE id = %s",
               buyer_id, now + 600, seat_id)
    return True
```

Two buyers reported that they both saw "seat held" for the same seat in the same second. Requests come in from many web workers at once. I want to know for certain whether two buyers can hold one seat, and I don't want another round of guessing. Don't write any files yet. Tell me which kind of check you would use for this, why that one, and what the setup would look like.
