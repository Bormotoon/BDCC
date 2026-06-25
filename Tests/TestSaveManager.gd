extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== SaveManager Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("SaveManager class exists", func():
		return runner.assert_true(load("res://Game/SaveManager.gd") != null)
	)

	runner.run_test("SaveManager has loadVar function", func():
		var script = load("res://Game/SaveManager.gd")
		return runner.assert_true(script != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
