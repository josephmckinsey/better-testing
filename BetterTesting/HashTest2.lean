import BetterTesting.Basic

/-! Version 2: baseValue = 20 (different from version 1) -/

def baseValue : Nat := 20
def usesBase : Nat := baseValue + 5

/-- info: baseValue has recursive hash: 10426916223901820473 -/
#guard_msgs in
#hash baseValue

/-- info: usesBase has recursive hash: 2265818564565385631 -/
#guard_msgs in
#hash usesBase
