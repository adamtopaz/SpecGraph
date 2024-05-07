import Lake
open Lake DSL

require proofwidgets from git "https://github.com/leanprover-community/ProofWidgets4" @ "v0.0.35"

package «SpecGraph» where
  -- add package configuration options here

@[default_target]
lean_lib «SpecGraph» where
  -- add library configuration options here
