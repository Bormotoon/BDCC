extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== SaveManager Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("loadVar with existing key", func():
		var data = {"name": "test", "value": 42}
		var result = SAVE.loadVar(data, "name", "default")
		return runner.assert_eq(result, "test")
	)

	runner.run_test("loadVar with missing key returns default", func():
		var data = {"name": "test"}
		var result = SAVE.loadVar(data, "missing", "default_value")
		return runner.assert_eq(result, "default_value")
	)

	runner.run_test("loadVar with null default", func():
		var data = {"name": "test"}
		var result = SAVE.loadVar(data, "missing", null)
		return runner.assert_eq(result, null)
	)

	runner.run_test("loadVar with int value", func():
		var data = {"count": 100}
		var result = SAVE.loadVar(data, "count", 0)
		return runner.assert_eq(result, 100)
	)

	runner.run_test("loadVar with float value", func():
		var data = {"ratio": 0.75}
		var result = SAVE.loadVar(data, "ratio", 0.0)
		return runner.assert_near(result, 0.75, 0.001)
	)

	runner.run_test("loadVar with array value", func():
		var data = {"items": [1, 2, 3]}
		var result = SAVE.loadVar(data, "items", [])
		return runner.assert_eq(result.size(), 3)
	)

	runner.run_test("loadVar with dict value", func():
		var data = {"settings": {"volume": 0.8}}
		var result = SAVE.loadVar(data, "settings", {})
		return runner.assert_true(result.has("volume"))
	)

	runner.run_test("loadVar with bool value", func():
		var data = {"enabled": true}
		var result = SAVE.loadVar(data, "enabled", false)
		return runner.assert_true(result)
	)

	runner.run_test("can_save returns bool", func():
		var result = SAVE.can_save()
		return runner.assert_true(typeof(result) == TYPE_BOOL)
	)

	runner.run_test("get_all_save_paths returns array", func():
		var result = SAVE.get_all_save_paths()
		return runner.assert_true(result is Array)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
