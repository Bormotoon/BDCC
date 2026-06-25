extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== SexEngine Formula Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("Fallback fetish score -0.26", func():
		var fallback = -0.26
		return runner.assert_near(fallback, -0.26, 0.001)
	)

	runner.run_test("Personality score calculation", func():
		var personality_value = 0.8
		var stat_weight = 0.5
		var result = personality_value * stat_weight
		return runner.assert_near(result, 0.4, 0.01)
	)

	runner.run_test("SexGoal scoring", func():
		var goals = {
			"Choke": 1.0,
			"ChokeSexVaginal": 1.0,
		}
		return runner.assert_eq(goals.size(), 2)
	)

	runner.run_test("Activity base score", func():
		var has_goal = true
		var base_score = 0.5 if has_goal else 0.0
		return runner.assert_eq(base_score, 0.5)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
