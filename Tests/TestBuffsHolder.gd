extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== BuffsHolder Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("BuffsHolder class exists", func():
		return runner.assert_true(load("res://Inventory/BuffsHolder.gd") != null)
	)

	runner.run_test("DodgeChanceBuff class exists", func():
		return runner.assert_true(load("res://Inventory/Buffs/DodgeChanceBuff.gd") != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
