import SpecGraph.Widget

@[spec_decl]
def a : Nat := 0

@[spec_decl]
def b : Nat := a

@[spec_decl]
theorem hb : a = b := rfl

@[spec_decl]
def c (e : Nat) (he : e = a + b) : Nat := a + b + e

@[spec_decl]
theorem hh (e : Nat) (he : e = a + b) : c e he = a + b + e := rfl

@[spec_decl]
def ff : Nat := 0

#spec_graph
