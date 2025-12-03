import BetterTesting.Basic
import Lean


open Lean Elab Command System

syntax (name := checkLineRemote) "#find_home" term : command -- declare the syntax

@[command_elab checkLineRemote]
def elabCheckLineRemote : CommandElab := fun stx => do
  let id := stx[1].getId
  let env ← getEnv

  -- 1. Get the declaration ranges (line/col info)
  let some ranges ← findDeclarationRanges? id
    | logInfo m!"{id} does not have range information (it might be a builtin)."

  -- 2. Find which module (file) defines this name
  match ← Lean.findModuleOf? id with
  | some modName =>
    -- 3. Resolve the module name to a file path
    let pathStr ← Lean.findLean (← Lean.getSrcSearchPath) modName

    logInfo m!"'{id}' is defined in {pathStr}"
    logInfo m!"Line: {ranges.range.pos.line}, Column: {ranges.range.pos.column}"

  | none =>
    -- It is in the current file
    logInfo m!"'{id}' is defined in the current file."
    logInfo m!"Line: {ranges.range.pos.line}, Column: {ranges.range.pos.column}"

-- Examples
#find_home List.map
-- Output:
-- 'List.map' is defined in /.../lib/lean/Init/Data/List/Basic.lean
-- Line: 15, Column: 0

#find_home Nat
-- Output:
-- 'Nat' is defined in /.../lib/lean/Init/Prelude.lean
-- Line: 104, Column: 0
