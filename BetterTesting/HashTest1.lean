import BetterTesting.Basic

def baseValue : Nat := 10
def usesBase : Nat := baseValue + 5

/-- info: baseValue has recursive hash: 16545843480113624120 -/
#guard_msgs in
#hash baseValue

/-- info: usesBase has recursive hash: 7597780525550254209 -/
#guard_msgs in
#hash usesBase
