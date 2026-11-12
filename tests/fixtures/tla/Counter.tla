---- MODULE Counter ----
\* Test fixture for the script tests. A counter climbs from 0 to Max and stops.
EXTENDS Naturals
CONSTANT Max
VARIABLE x

Init == x = 0
Next == x < Max /\ x' = x + 1
Spec == Init /\ [][Next]_x
FairSpec == Spec /\ WF_x(Next)

Bounded == x <= Max
NeverMax == x < Max
ReachesMax == <>(x = Max)
====
