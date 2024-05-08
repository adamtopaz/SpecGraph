import SpecGraph.Types

open Lean

initialize specEnvExt :
    SimplePersistentEnvExtension Name NameSet ← registerSimplePersistentEnvExtension {
  addEntryFn := .insert
  addImportedFn := fun as => Id.run do
    let mut out := {}
    for a in as do
      for b in a do
        out := out.insert b
    return out
}

syntax (name := spec_decl) "spec_decl" : attr

def specAttrImpl : AttributeImpl where
  name := `spec_decl
  descr := ""
  add := fun nm stx _ => match stx with
  | `(attr|spec_decl) => modifyEnv fun env => specEnvExt.addEntry env nm
  | _ => Elab.throwUnsupportedSyntax

initialize registerBuiltinAttribute specAttrImpl

def specGraph : CoreM (HashGraph Name) := do
  let env ← getEnv
  let names := specEnvExt.getState env
  let mut graph : HashGraph Name := {}
  for a in names do
    graph := graph.insertNode a
    let some c := env.find? a | continue
    for b in names do
      if c.getUsedConstantsAsSet.contains b then
        graph := graph.insertEdge b a
  return graph

def specGraphOf (nm : Name) (gas := 5) : CoreM (HashGraph Name) :=
match gas with
| 0 => return .mk (HashSet.empty.insert nm) {}
| n+1 => do
  let env ← getEnv
  let specDecls := specEnvExt.getState env
  let prev ← specGraphOf nm n
  let mut out := prev
  for decl in specDecls do
    let some c := env.find? decl | continue
    for p in prev.nodes do
      if c.getUsedConstantsAsSet.contains p then out := out.insertEdge p decl
  return out
