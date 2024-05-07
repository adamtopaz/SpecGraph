import ProofWidgets.Component.HtmlDisplay

open Lean ProofWidgets
open scoped ProofWidgets.Jsx

structure RubiksProps where
  dot : String := "digraph  {a -> c}"
  deriving ToJson, FromJson, Inhabited

@[widget_module]
def Rubiks : Component RubiksProps where
  javascript := include_str ".." / "widget" / "dist" / "index.mjs"

#html <Rubiks dot="digraph {ab -> C; ab -> D;}" />
