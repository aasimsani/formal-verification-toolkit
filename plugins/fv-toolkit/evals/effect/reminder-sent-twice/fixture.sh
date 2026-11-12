#!/usr/bin/env bash
# Seeds the workspace for this case. `claude plugin eval --scaffold` runs it outside the sandbox.
set -euo pipefail
git init -q -b main .
git config user.email dev@example.com
git config user.name Dev
mkdir -p reminders

cat > CLAUDE.md <<'MD'
# Payment reminders

`reminders/queue.py` is a job queue with leases. `reminders/worker.py` leases a reminder, sends it and acknowledges it.

## Tools on this machine
- This machine has no network access.
- `python3` is installed with its standard library. Nothing else needs to be installed.
MD

: > reminders/__init__.py
cat > reminders/queue.py <<'PY'
"""A job queue with leases. Time comes from the clock that the caller passes in."""


class Queue:
    def __init__(self, clock, lease_seconds=30):
        self.clock = clock
        self.lease_seconds = lease_seconds
        self.jobs = {}    # job id -> payload
        self.leases = {}  # job id -> (worker name, time the lease ends)

    def put(self, job_id, payload):
        self.jobs[job_id] = payload

    def lease(self, worker):
        """Return the id of a job that no live lease covers, or None."""
        now = self.clock()
        for job_id in sorted(self.jobs):
            holder = self.leases.get(job_id)
            if holder is None or holder[1] <= now:
                self.leases[job_id] = (worker, now + self.lease_seconds)
                return job_id
        return None

    def ack(self, worker, job_id):
        """Remove a finished job."""
        if job_id in self.jobs:
            del self.jobs[job_id]
            self.leases.pop(job_id, None)
PY

cat > reminders/worker.py <<'PY'
"""A worker takes one reminder at a time. Each method is one step, and other workers run between steps."""


class Worker:
    def __init__(self, name, queue, outbox):
        self.name = name
        self.queue = queue
        self.outbox = outbox  # every reminder that was sent, as job ids
        self.current = None

    def take(self):
        if self.current is None:
            self.current = self.queue.lease(self.name)

    def send(self):
        """Send the reminder of the job this worker holds."""
        if self.current is not None:
            self.outbox.append(self.current)

    def finish(self):
        if self.current is not None:
            self.queue.ack(self.name, self.current)
            self.current = None

    def crash(self):
        """Lose the job in memory. The lease stays in the queue until it ends."""
        self.current = None
PY
git add -A && git commit -qm "payment reminders"
