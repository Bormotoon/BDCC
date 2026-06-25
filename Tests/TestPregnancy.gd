extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== Pregnancy System Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("MenstrualCycle class exists", func():
		return runner.assert_true(load("res://Game/Pregnancy/MenstrualCycle.gd") != null)
	)

	runner.run_test("EggCell class exists", func():
		return runner.assert_true(load("res://Game/Pregnancy/EggCell.gd") != null)
	)

	runner.run_test("EggLaid class exists", func():
		return runner.assert_true(load("res://Game/Pregnancy/EggLaid.gd") != null)
	)

	runner.run_test("Child class compiles", func():
		var script = load("res://Game/Pregnancy/Child.gd")
		return runner.assert_true(script != null and script.can_instantiate())
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
