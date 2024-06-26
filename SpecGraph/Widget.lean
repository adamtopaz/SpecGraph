import GraphWidget
import SpecGraph.Init

open Lean ProofWidgets
open scoped ProofWidgets.Jsx

def Lean.Name.usesSorry (name : Name) : CoreM Bool := do
  let some c := (← getEnv).find? name | throwError s!"{name} not found in environment."
  return c.getUsedConstantsAsSet.contains ``sorryAx

def mkNodes (nodes : HashSet Name) : MetaM (Array Node) :=
  nodes.toArray.filterMapM fun nm => do
    let env ← getEnv
    let some c := env.find? nm | return none
    let ppTp ← Meta.ppExpr c.type
    let docString : String :=
      match ← findDocString? env nm with
      | none => ""
      | some doc => s!"\n---\n{doc}\n---\n"
    return some {
      id := s!"{hash nm}",
      --name := nm
      info := s!"\
# `{nm}`
```lean
{nm} : {ppTp}
```
{docString}
"
    }

def mkDot (graph : HashGraph Name) : MetaM String := do
  let mut out := "digraph {\n"
  let nodes ← mkNodes graph.nodes
  for (node, name) in nodes.zip graph.nodes.toArray do
    let color : String := if ← name.usesSorry then "red" else "green"
    out := out ++ s!"  {node.id} [label=\"{name}\", id={node.id}, color={color}];\n"
  for (a,b) in graph.edges do
    out := out ++ s!"  {hash a} -> {hash b};\n"
  return out ++ "}"

syntax (name := specGraphCmd) "#spec_graph " : command

open Elab Command Json in
@[command_elab specGraphCmd]
def elabSpecGraphCmd : CommandElab := fun
  | stx@`(#spec_graph) =>
    runTermElabM fun _ => do
      let graph ← specGraph
      let nodes ← mkNodes graph.nodes
      let dot ← mkDot graph
      let ht : Html := <Graph nodes={nodes} dot={dot}/>
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
      let ht : Html := <Graph nodes={nodes} dot={dot}/>
      Widget.savePanelWidgetInfo (hash HtmlDisplayPanel.javascript)
        (return json% { html: $(← Server.rpcEncode ht) }) stx
  | stx => throwError "Unexpected syntax {stx}."
