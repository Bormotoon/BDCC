extends Node

var tests_passed: int = 0
var tests_failed: int = 0
var tests_total: int = 0

func run_test(test_name: String, test_func: Callable) -> void:
	tests_total += 1
	var result = test_func.call()
	if result:
		tests_passed += 1
		print("  PASS: " + test_name)
	else:
		tests_failed += 1
		print("  FAIL: " + test_name)

func assert_eq(actual, expected) -> bool:
	if actual == expected:
		return true
	print("    Expected: " + str(expected))
	print("    Got:      " + str(actual))
	return false

func assert_near(actual: float, expected: float, tolerance: float) -> bool:
	if absf(actual - expected) <= tolerance:
		return true
	print("    Expected: ~" + str(expected) + " (±" + str(tolerance) + ")")
	print("    Got:      " + str(actual))
	return false

func assert_true(value: bool) -> bool:
	if value:
		return true
	print("    Expected: true, Got: " + str(value))
	return false

func assert_false(value: bool) -> bool:
	if not value:
		return true
	print("    Expected: false, Got: " + str(value))
	return false
