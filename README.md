# better-testing

# Wish List

- [ ] Summary of passing and failing tests
- [ ] Grouping tests
- [ ] Group tests by file
- [ ] Filtering tests
- [ ] Tag tests
- [ ] Use attributes or macros
- [ ] Run only failing tests
- [ ] Do not rerun (pure) tests that haven't changed
- [ ] Code coverage (including theorem-coverage)
- [ ] Recovery on panic. (How does the lean language server do it)
- [ ] Metaprogramming tests (like guard_msgs but with other nice testing features).
- [ ] A `Testable f` class which specifies how to test a function.
- [ ] It should be easy to import tests into a GUI, i.e. to inspect failing tests (and their logs?)
- [ ] IDE integration of tests
- [ ] It should be easy to diff tests over time (e.g. to identify flaky tests)
- [ ] Test failures should point at the line number, etc.
- [ ] Capturing stdin/stdout per test.
- [ ] Guess which tests are applicable for a change
- [ ] Guess which diff broke a test
- [ ] Pure environments for impure tests.
- [ ] Greatest common ancestor test which fails
- [ ] Parallel tests
- [ ] Property testing
- [ ] Tracking of sorry's becoming property tests, then become theorems later.
- [ ] Performance testing
- [ ] Mutation testing of theorems
- [ ] Fuzzing
- [ ] Monitoring and observability

## Past Notes

```
-- All test functions should name by default. This is the unit
-- things filter on.

@[test, testTags ["network"]] -- automatically adds it to a file group
def testTheThing : TestM Unit := testFunction "manual test" do 
	test "1 = 0" (1 == 0)
	test "2 = 2" (2 == 2)

-- Adds to the "normalization" group instead.
@[test (group := "Normalization")]
def testTheThing : TestM Unit := testFunction "manual test" do 
	test "1 = 0" (1 == 0)
	test "2 = 2" (2 == 2)

def testFunctionManually : TestM Unit := testFunction "manual test" do
	test "thing" true

-- If you need to add it to the top level group.
@[test (topLevel := true)] -- Adds it to the same group as file groups.
def testGroup : TestM Unit := group "Group Test" do
	testFunctionManually
```

Right now, the only real testing library in Lean is [LSpec](https://github.com/argumentcomputer/LSpec). I don't like LSpec that much, but maybe I just wanted to reinvent the wheel. The current stuff I use is at https://github.com/josephmckinsey/lean-uri/blob/main/UriTesting/Helpers.lean.

There is also https://github.com/leanprover-community/plausible

# Technical Challenges

- How do I reroute stdin, stdout of a test?

https://leanprover-community.github.io/mathlib4_docs/Init/System/IO.html#IO.setStdout

- How do I get line numbers ranges of a declaration?

Also see https://github.com/leanprover-community/import-graph/blob/6e3bb4bf31f731ab28891fe229eb347ec7d5dad3/ImportGraph/RequiredModules.lean#L19-L27

See `elabCheckLineRemote` in `BetterTesting/DebugModule.lean`.

- How do I compute a hash of a declaration which includes dependencies?

As above, see the import-graph library.

See `computeRecursiveHashAux` in `BetterTesting/Basic.lean`

- How do I annotate functions with code coverage tracking?

??? In general it would be nice to hook into code gen for monitoring or whatever.

- How do I tell if a function is pure or not?

??? Does it reference a bad constant like IO?

- How do you recover from panic?

This doesn't always crash the language server.

```lean
def arr : Array Int := #[1, 2]

#eval arr[3]!
```

- How do IDEs (VS Code) handle tests?

I personally never use the IDE test integration.

- Where do we store the test information of the last run test?

It would be nice for this to work in Github CI/CD.

# Design Questions

## Test registration

Different language frameworks make very different choices:

1. Using specific naming schemes (like pytest)
2. Put things in classes or data structure (like python's unittest library, or Haskell's HSpec)
3. Register it globally (like Julia's `@testset` or `describe()`)
4. Register using a compiler attribute (C#'s `[Fact]` attribute)
5. Tests have a specific signature (Go's `t *testing.T`)

There is an element here on how involved metaprogramming should be in tests, since
tests should have line numbers and Lean.Expr hashing, metaprogramming is very attractive.

## IO Monad or Pure

Capturing stdin and stdout would require using the IO monad, but there's a lot
you can do if you know the tests are pure ahead of time.

## Test grouping and filtering

Options here:
- Manual grouping in a group data structure (or nested functions)
- Group by file/directory
- Manual tags
- Are there multiple levels of groups?

When you filter, do you filter all groups, the lowest level? `pytest` filters on the function name, which can be very convenient.

## Test fixtures

Do we even have test fixtures, or is that part of a "manual grouping" strategy?

## Typeclasses?

Do we have `Testable` type classes? There's already two existing `Testable` classes.

## Extra Features: property testing, fuzzing, performance testing, parallel testing, etc.

Are these "plugins" somehow or closure?

## GUI

Are we making a GUI too?

## Sorry-Tracking

Lean 4's blueprint is a nice tool for tracking efforts on formalizing well-known proofs, but it doesn't have any options for testing. Is that the best place to add tracking of theorems vs tests?

This seems tricky to get right.
