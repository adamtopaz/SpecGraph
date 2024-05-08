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


structure FF where
  x : Nat
  hx : x = a


attribute [spec_decl] a b c foo FF.hx

#spec_graph
