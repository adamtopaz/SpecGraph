import SpecGraph.Widget

@[spec_decl]
def a : Nat := 0

@[spec_decl]
def b : Nat := a

@[spec_decl]
def c : Nat := a + b

notation "ℕ" => Nat

@[spec_decl]
def foo : ℕ → ℕ := fun x => x + a + b + c

#spec_graph
