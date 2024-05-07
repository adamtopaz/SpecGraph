import Lean

open Lean

structure HashGraph (α : Type) [BEq α] [Hashable α] where
  nodes : HashSet α
  edges : HashSet (α × α)

namespace HashGraph

variable {α : Type} [BEq α] [Hashable α]

def insertNode (G : HashGraph α) (a : α) : HashGraph α where
  nodes := G.nodes.insert a
  edges := G.edges

def insertEdge (G : HashGraph α) (a b : α) : HashGraph α where
  nodes := G.nodes.insertMany [a,b]
  edges := G.edges.insert (a,b)

def toDot (G : HashGraph α) [ToString α] : String := Id.run do
  let mut out := "digraph {\n"
  for n in G.nodes do
    out := out ++ s!"  \"{n}\";\n"
  for (a,b) in G.edges do
    out := out ++ s!"  \"{a}\" -> \"{b}\";\n"
  return out ++ "}"

instance : EmptyCollection (HashGraph α) where
  emptyCollection := ⟨{}, {}⟩

end HashGraph
