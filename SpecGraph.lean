import SpecGraph.Widget

universe u

/--
We introduce a natural number $a$, and set it equal to $0$.
-/
@[spec_decl]
def a := 0

/--
Now we introduce another natural number $b$,
which is just the sum of $a$ and $0$.
-/
@[spec_decl]
def b := a + 0

#spec_graph
