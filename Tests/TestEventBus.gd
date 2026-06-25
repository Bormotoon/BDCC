extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== EventBus Signal Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("EventBus has time_advanced signal", func():
		return runner.assert_true(EventBus.has_signal("time_advanced"))
	)

	runner.run_test("EventBus has pain_changed signal", func():
		return runner.assert_true(EventBus.has_signal("pain_changed"))
	)

	runner.run_test("EventBus has lust_changed signal", func():
		return runner.assert_true(EventBus.has_signal("lust_changed"))
	)

	runner.run_test("EventBus has sex_event_triggered signal", func():
		return runner.assert_true(EventBus.has_signal("sex_event_triggered"))
	)

	runner.run_test("EventBus has item_added signal", func():
		return runner.assert_true(EventBus.has_signal("item_added"))
	)

	runner.run_test("EventBus has level_changed signal", func():
		return runner.assert_true(EventBus.has_signal("level_changed"))
	)

	runner.run_test("EventBus has npc_spawned signal", func():
		return runner.assert_true(EventBus.has_signal("npc_spawned"))
	)

	runner.run_test("EventBus has scene_started signal", func():
		return runner.assert_true(EventBus.has_signal("scene_started"))
	)

	runner.run_test("EventBus has save_started signal", func():
		return runner.assert_true(EventBus.has_signal("save_started"))
	)

	runner.run_test("EventBus has new_day_started signal", func():
		return runner.assert_true(EventBus.has_signal("new_day_started"))
	)

	runner.run_test("EventBus has hour_passed signal", func():
		return runner.assert_true(EventBus.has_signal("hour_passed"))
	)

	runner.run_test("EventBus signal count > 20", func():
		var count = EventBus.get_signal_list().size()
		return runner.assert_true(count > 20)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
