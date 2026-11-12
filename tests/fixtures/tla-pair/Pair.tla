---- MODULE Pair ----
EXTENDS Naturals, Sequences
\* Test fixture for the script tests. Two workers each move from idle to busy.
CONSTANT Procs
VARIABLES pc, log

vars == <<pc, log>>
Init == pc = [p \in Procs |-> "idle"] /\ log = <<>>
Start(p) == pc[p] = "idle" /\ pc' = [pc EXCEPT ![p] = "busy"] /\ log' = Append(log, [who |-> p, n |-> Len(log) + 1])
Done == (\A p \in Procs : pc[p] = "busy") /\ UNCHANGED vars
Next == (\E p \in Procs : Start(p)) \/ Done
Spec == Init /\ [][Next]_vars
NeverAllBusy == \E p \in Procs : pc[p] = "idle"
====
