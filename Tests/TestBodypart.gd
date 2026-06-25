extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== Bodypart System Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("Bodypart class exists", func():
		return runner.assert_true(load("res://Player/Bodyparts/Bodypart.gd") != null)
	)

	runner.run_test("BodypartSlot class exists", func():
		return runner.assert_true(load("res://Player/Bodyparts/BodypartSlot.gd") != null)
	)

	runner.run_test("BodypartBreasts class exists", func():
		return runner.assert_true(load("res://Player/Bodyparts/BodypartBreasts.gd") != null)
	)

	runner.run_test("BodypartPenis class exists", func():
		return runner.assert_true(load("res://Player/Bodyparts/BodypartPenis.gd") != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
