-- Test fixture for the script tests.
sig Node { link: lone Node }

pred hasEdge { some link }
assert AtMostOneNext { all n: Node | lone n.link }
assert NoSelfLoop { no n: Node | n in n.link }

run hasEdge for 3 expect 1
check AtMostOneNext for 3 expect 0
check NoSelfLoop for 3 expect 1
