import ProofWidgets.Component.HtmlDisplay
import SpecGraph.Init

open Lean ProofWidgets
open scoped ProofWidgets.Jsx

structure Node where
  id : String
  name : Name
  type : String
  docstring : Option String
deriving ToJson, FromJson, Inhabited

structure Edge where
  source : String
  target : String
deriving ToJson, FromJson, Inhabited

structure SpecGraphProps where
  nodes : Array Node
  edges : Array Edge
deriving ToJson, FromJson, Inhabited

@[widget_module]
def SpecGraph : Component SpecGraphProps where
  javascript := include_str ".." / "widget" / "dist" / "index.mjs"

syntax (name := htmlCmd) "#spec_graph " : command

open Elab Command Json in
@[command_elab htmlCmd]
def elabHtmlCmd : CommandElab := fun
  | stx@`(#spec_graph) =>
    runTermElabM fun _ => do
      let graph ← specGraph
      let mut nodes := #[]
      let env ← getEnv
      for n in graph.nodes do
        let some c := env.find? n | continue
        let ppTp ← Meta.ppExpr c.type
        let docString? ← findDocString? env n
        nodes := nodes.push { id := s!"{n}", name := n, type := s!"{ppTp}", docstring := docString? }
      let mut edges := #[]
      for (source, target) in graph.edges do
        edges := edges.push { source := s!"{source}", target := s!"{target}" }
      let ht : Html := <SpecGraph nodes={nodes} edges={edges}/>
      Widget.savePanelWidgetInfo (hash HtmlDisplayPanel.javascript)
        (return json% { html: $(← Server.rpcEncode ht) }) stx
  | stx => throwError "Unexpected syntax {stx}."
