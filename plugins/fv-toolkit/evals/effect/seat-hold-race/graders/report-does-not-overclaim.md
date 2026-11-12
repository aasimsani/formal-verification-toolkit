---
# A bounded check is never reported as a proof.
type: regex
target: { source: file, path: formal/REPORT.md }
pattern: 'formally verified|proved correct|proven correct|is now correct'
flags: i
match: not_contains
---
