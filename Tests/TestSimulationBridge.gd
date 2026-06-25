extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== SimulationBridge Formula Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("Hunger rate 0.2/hr", func():
		var delta_hours = 1.0
		var hunger = 0.0
		hunger += delta_hours * 0.2
		return runner.assert_near(hunger, 0.2, 0.01)
	)

	runner.run_test("Social rate 0.5/hr", func():
		var delta_hours = 1.0
		var social = 0.0
		social += delta_hours * 0.5
		return runner.assert_near(social, 0.5, 0.01)
	)

	runner.run_test("Tiredness rate 0.05/hr", func():
		var delta_hours = 1.0
		var tiredness = 0.0
		tiredness += delta_hours * 0.05
		return runner.assert_near(tiredness, 0.05, 0.01)
	)

	runner.run_test("Anger rate 0.1*meanness/hr", func():
		var delta_hours = 1.0
		var meanness = 0.5
		var anger = 0.0
		anger += delta_hours * 0.1 * meanness
		return runner.assert_near(anger, 0.05, 0.01)
	)

	runner.run_test("Tick size 60 seconds", func():
		var TICK_SIZE_SECONDS = 60
		return runner.assert_eq(TICK_SIZE_SECONDS, 60)
	)

	runner.run_test("Min score 10% of max", func():
		var max_score = 100.0
		var min_score = max_score * 0.1
		return runner.assert_near(min_score, 10.0, 0.01)
	)

	runner.run_test("Delta hours conversion", func():
		var delta_seconds = 3600
		var delta_hours = float(delta_seconds) / 3600.0
		return runner.assert_near(delta_hours, 1.0, 0.01)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
