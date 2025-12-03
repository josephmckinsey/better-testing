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
