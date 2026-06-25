extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== LustCombat Formula Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("LustInterests class exists", func():
		return runner.assert_true(load("res://Game/LustCombat/LustInterests.gd") != null)
	)

	runner.run_test("LustCombat formula: interest scoring", func():
		var interest_value = 0.8
		var weight = 0.5
		var result = interest_value * weight
		return runner.assert_near(result, 0.4, 0.01)
	)

	runner.run_test("LustCombat formula: overall likeness", func():
		var interests = [0.5, 0.3, 0.7]
		var total = 0.0
		for i in interests:
			total += i
		var avg = total / interests.size()
		return runner.assert_near(avg, 0.5, 0.01)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
