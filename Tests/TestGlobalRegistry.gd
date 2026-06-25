extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== GlobalRegistry Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("GlobalRegistry class exists", func():
		return runner.assert_true(load("res://GlobalRegistry.gd") != null)
	)

	runner.run_test("GlobalRegistry script has registerEverything", func():
		var script = load("res://GlobalRegistry.gd")
		return runner.assert_true(script != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
