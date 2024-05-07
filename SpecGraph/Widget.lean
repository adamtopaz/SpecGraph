import ProofWidgets.Component.HtmlDisplay
import SpecGraph.Init

open Lean ProofWidgets
open scoped ProofWidgets.Jsx

structure SpecGraphProps where
  dot : String := "digraph  {}"
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
      let mut dot := "digraph {\n"
      for (a,b) in graph do
        dot := dot ++ s!"\"{a}\" -> \"{b}\";\n"
      dot := dot ++ "}"
      --let s : String := "digraph {ab -> Csd; abaa -> Csd; a -> asd;}"
      let ht : Html := <SpecGraph dot={dot}/>
      Widget.savePanelWidgetInfo (hash HtmlDisplayPanel.javascript)
        (return json% { html: $(← Server.rpcEncode ht) }) stx
  | stx => throwError "Unexpected syntax {stx}."
