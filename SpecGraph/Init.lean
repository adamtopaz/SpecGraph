import Lean

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

def specGraph : CoreM (HashSet (Name × Name)) := do
  let env ← getEnv
  let names := specEnvExt.getState env
  let mut graph : HashSet (Name × Name) := {}
  for a in names do
    let some c := env.find? a | continue
    for b in names do
      if c.getUsedConstantsAsSet.contains b then
        graph := graph.insert (b,a)
  return graph
