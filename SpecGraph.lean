import SpecGraph.Widget

@[spec_decl]
def a : Nat := 0

@[spec_decl]
theorem ha : a = 0 := rfl

structure A where
  b : Nat
  hb : b = a

@[spec_decl]
def b : Nat := a + 2

structure B where
  c : Nat
  hc : c + a + b = 0

attribute [spec_decl] A.hb B.hc

#spec_graph
