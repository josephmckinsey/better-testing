import Lean
import Std.Data.HashMap

open Lean Elab Command
open Std (HashMap)

/--
Compute a recursive hash for a constant that includes hashes of all
constants it depends on. The hash changes whenever the definition or
any of its transitive dependencies change.

Uses StateT to cache results and avoid recomputation.

The `fuel` parameter limits recursion depth.
-/
partial def computeRecursiveHashAux [Monad m] [MonadEnv m] (name : Name) (fuel : Nat := 100) :
    StateT (HashMap Name UInt64) m UInt64 := do
  let cache ← get
  if let some h := cache[name]? then
    return h

  -- Don't look _too_ hard
  if fuel = 0 then
    return hash name

  let env ← getEnv
  let some ci := env.find? name
    | return 0  -- Constant not found :(

  -- Start with hash of the constant's own definition
  -- Hash the name, type and value expressions,
  let mut h : UInt64 := mixHash (hash ci.type) (hash name)
  h := match ci.value? with -- definitions, theorems, and opaque constants
    | some v => mixHash h (hash v)
    | none => h

  -- Then add used constants
  let usedConsts := ci.getUsedConstantsAsSet

  -- ctors like Nat.zero reference Nat, which reference their .ctors...
  let usedConsts := match ci with
    | .ctorInfo ctor => usedConsts.erase ctor.induct -- we break that loop
    | _ => usedConsts

  for dep in usedConsts do
    let depHash ← computeRecursiveHashAux dep (fuel - 1)
    h := mixHash h depHash

  modify (·.insert name h)
  return h

/--
Compute recursive hash for a constant.

Returns a hash that changes whenever the definition or any of its
transitive dependencies change.
-/
def computeConstantHash [Monad m] [MonadEnv m] (name : Name) (fuel : Nat := 100) : m UInt64 := do
  let (h, _cache) ← (computeRecursiveHashAux name fuel).run (HashMap.emptyWithCapacity 64)
  return h

/--
Command to compute and display the recursive hash of a constant.
Usage: #hash ConstantName
-/
elab "#hash" id:ident : command => do
  -- Resolve the identifier in the current namespace
  let constName ← liftCoreM <| realizeGlobalConstNoOverloadWithInfo id
  let env ← getEnv

  -- Check if the constant exists
  match env.find? constName with
  | none => logError s!"Unknown constant: {constName}"
  | some _ =>
    let h ← computeConstantHash constName
    logInfo s!"{constName} has recursive hash: {h}"

/--
Command to hash all definitions in the current module.
Usage: #hash_module
-/
elab "#hash_module" : command => do
  let env ← getEnv

  -- Count total constants in environment
  let totalConsts := env.constants.fold (init := 0) fun count _ _ => count + 1

  -- Collect all constants that have no module index (i.e., defined in current module)
  let moduleConsts := env.constants.fold (init := #[]) fun acc name _ =>
    match env.getModuleIdxFor? name with
    | none => acc.push name  -- No module index = defined in current module
    | some _ => acc          -- Has module index = imported

  logInfo s!"Environment: {totalConsts} total constants, {moduleConsts.size} in current module"

  if moduleConsts.size > 0 then
    -- Filter out compiler-generated auxiliary declarations for cleaner output
    let userConsts := moduleConsts.filter fun name =>
      let nameStr := name.toString
      -- If splitOn returns > 1 element, the substring was found
      -- Why is string "containsSubstr" in Batteries???
      (nameStr.splitOn "_proof_").length == 1 &&
      (nameStr.splitOn ".match_").length == 1 &&
      (nameStr.splitOn "_unsafe_").length == 1 &&
      (nameStr.splitOn ".eq_").length == 1

    logInfo s!"  ({userConsts.size} user definitions, {moduleConsts.size - userConsts.size} auxiliary)"

    let startTime ← IO.monoMsNow

    let mut cache : HashMap Name UInt64 := HashMap.emptyWithCapacity 4096
    for name in moduleConsts do
      let (_, newCache) ← (computeRecursiveHashAux name).run cache
      cache := newCache

    let endTime ← IO.monoMsNow
    logInfo s!"Completed in {endTime - startTime}ms (cache: {cache.size} constants)"
  else
    logInfo s!"(No definitions found in current module)"

elab "#hash_all_constants" : command => do
  let env ← getEnv

  -- Collect ALL constants in the environment
  let allConsts := env.constants.fold (init := #[]) fun acc name _ => acc.push name

  logInfo s!"Hashing ALL {allConsts.size} constants in environment..."
  logInfo s!"(This may take a while...)"

  let startTime ← IO.monoMsNow

  -- Use a shared cache for maximum performance
  let mut cache : HashMap Name UInt64 := HashMap.emptyWithCapacity 8192
  for name in allConsts do
    let (_, newCache) ← (computeRecursiveHashAux name).run cache
    cache := newCache

  let endTime ← IO.monoMsNow
  let elapsed := endTime - startTime

  logInfo s!"Completed in {elapsed}ms ({(elapsed.toFloat / 1000.0).toString}s)"
  logInfo s!"Cache size: {cache.size} unique constants"
  logInfo s!"Average: {elapsed.toFloat / allConsts.size.toFloat}ms per constant"

-- Simple test definition
def hello := "world"
