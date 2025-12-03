import BetterTesting.Basic

/-!
A more complex file to test hashing performance.
-/

-- Basic arithmetic functions
def add (x y : Nat) : Nat := x + y
def mul (x y : Nat) : Nat := x * y
def square (x : Nat) : Nat := mul x x
def cube (x : Nat) : Nat := mul x (square x)

-- Recursive functions
def factorial : Nat → Nat
  | 0 => 1
  | n + 1 => (n + 1) * factorial n

def fibonacci : Nat → Nat
  | 0 => 0
  | 1 => 1
  | n + 2 => fibonacci n + fibonacci (n + 1)

-- List operations
def listSum : List Nat → Nat
  | [] => 0
  | x :: xs => x + listSum xs

def listProduct : List Nat → Nat
  | [] => 1
  | x :: xs => x * listProduct xs

def listLength {α : Type} : List α → Nat
  | [] => 0
  | _ :: xs => 1 + listLength xs

def listMap {α β : Type} (f : α → β) : List α → List β
  | [] => []
  | x :: xs => f x :: listMap f xs

def listFilter {α : Type} (p : α → Bool) : List α → List α
  | [] => []
  | x :: xs => if p x then x :: listFilter p xs else listFilter p xs

-- Custom data types
inductive Tree (α : Type) where
  | leaf : α → Tree α
  | node : Tree α → Tree α → Tree α

def treeSize {α : Type} : Tree α → Nat
  | .leaf _ => 1
  | .node l r => 1 + treeSize l + treeSize r

def treeMap {α β : Type} (f : α → β) : Tree α → Tree β
  | .leaf x => .leaf (f x)
  | .node l r => .node (treeMap f l) (treeMap f r)

-- More complex structures
structure Point where
  x : Float
  y : Float

def Point.add (p1 p2 : Point) : Point :=
  { x := p1.x + p2.x, y := p1.y + p2.y }

def Point.distance (p1 p2 : Point) : Float :=
  let dx := p1.x - p2.x
  let dy := p1.y - p2.y
  Float.sqrt (dx * dx + dy * dy)

-- Option and Result types
def optionMap {α β : Type} (f : α → β) : Option α → Option β
  | none => none
  | some x => some (f x)

def optionBind {α β : Type} (x : Option α) (f : α → Option β) : Option β :=
  match x with
  | none => none
  | some a => f a

-- String operations
def stringReverse (s : String) : String :=
  s.toList.reverse.asString

def stringLength (s : String) : Nat :=
  s.length

-- Higher-order functions
def compose {α β γ : Type} (f : β → γ) (g : α → β) (x : α) : γ :=
  f (g x)

def twice {α : Type} (f : α → α) (x : α) : α :=
  f (f x)

def iterate {α : Type} (f : α → α) (n : Nat) (x : α) : α :=
  match n with
  | 0 => x
  | n + 1 => f (iterate f n x)

-- Hash all definitions in this module
#hash_module
