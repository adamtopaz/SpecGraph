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

def Node.usesSorry (node : Node) : CoreM Bool := do
  let some c := (← getEnv).find? node.name | throwError s!"{node.name} not found in environment."
  return c.getUsedConstantsAsSet.contains ``sorryAx

structure Edge where
  source : String
  target : String
deriving ToJson, FromJson, Inhabited

structure SpecGraphProps where
  nodes : Array Node
  dot : String
deriving ToJson, FromJson, Inhabited

@[widget_module]
def SpecGraph : Component SpecGraphProps where
  javascript := include_str ".." / "build" / "js" / "specgraph.js"

syntax (name := specGraphCmd) "#spec_graph " : command

def mkNodes (nodes : HashSet Name) : MetaM (Array Node) :=
  nodes.toArray.filterMapM fun nm => do
    let env ← getEnv
    let some c := env.find? nm | return none
    return some {
      id := s!"{hash nm}",
      name := nm,
      type := (← Meta.ppExpr c.type).pretty
      docstring := ← findDocString? env nm
    }

def mkDot (graph : HashGraph Name) : MetaM String := do
  let mut out := "digraph {\n"
  let nodes ← mkNodes graph.nodes
  for node in nodes do
    let color : String := if ← node.usesSorry then "red" else "green"
    out := out ++ s!"  {node.id} [label=\"{node.name}\", id={node.id}, color={color}];\n"
  for (a,b) in graph.edges do
    out := out ++ s!"  {hash a} -> {hash b};\n"
  return out ++ "}"

open Elab Command Json in
@[command_elab specGraphCmd]
def elabSpecGraphCmd : CommandElab := fun
  | stx@`(#spec_graph) =>
    runTermElabM fun _ => do
      let graph ← specGraph
      let nodes ← mkNodes graph.nodes
      let dot ← mkDot graph
      let ht : Html := <SpecGraph nodes={nodes} dot={dot}/>
      Widget.savePanelWidgetInfo (hash HtmlDisplayPanel.javascript)
        (return json% { html: $(← Server.rpcEncode ht) }) stx
  | stx => throwError "Unexpected syntax {stx}."

syntax (name := specGraphOfCmd) "#spec_graph_of" ident (num)? : command

open Elab Command Json in
@[command_elab specGraphOfCmd]
def elabSpecGraphOfCmd : CommandElab := fun
  | stx@`(#spec_graph_of $i:ident $[$n:num]?) =>
    runTermElabM fun _ => do
      let i := i.getId
      let gas := match n with
        | none => 5
        | some n => n.getNat
      let graph ← specGraphOf i gas
      let nodes ← mkNodes graph.nodes
      let dot ← mkDot graph
      let ht : Html := <SpecGraph nodes={nodes} dot={dot}/>
      Widget.savePanelWidgetInfo (hash HtmlDisplayPanel.javascript)
        (return json% { html: $(← Server.rpcEncode ht) }) stx
  | stx => throwError "Unexpected syntax {stx}."
