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

@[spec_decl]
structure F where
  x : Nat
  ha : x = a

@[spec_decl]
theorem tt {f : F} : f.x = a := f.ha

#spec_graph
