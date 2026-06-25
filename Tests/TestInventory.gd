extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== Inventory System Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("Inventory class exists", func():
		return runner.assert_true(load("res://Inventory/Inventory.gd") != null)
	)

	runner.run_test("ItemBase class exists", func():
		return runner.assert_true(load("res://Inventory/ItemBase.gd") != null)
	)

	runner.run_test("BuffsHolder class exists", func():
		return runner.assert_true(load("res://Inventory/BuffsHolder.gd") != null)
	)

	runner.run_test("SmartLockBase class exists", func():
		return runner.assert_true(load("res://Inventory/SmartLocks/SmartLockBase.gd") != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
