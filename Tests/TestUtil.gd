extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== Util Function Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("remapValue", func():
		var value = 0.5
		var result = (value - 0.0) / (1.0 - 0.0) * (100.0 - 0.0) + 0.0
		return runner.assert_near(result, 50.0, 0.01)
	)

	runner.run_test("String interpolation", func():
		var text = "Hello {name}!"
		var args = {"name": "World"}
		var result = text.format(args)
		return runner.assert_eq(result, "Hello World!")
	)

	runner.run_test("Dictionary merge", func():
		var dict1 = {"a": 1, "b": 2}
		var dict2 = {"b": 3, "c": 4}
		var result = dict1.duplicate()
		result.merge(dict2, true)
		return runner.assert_eq(result, {"a": 1, "b": 3, "c": 4})
	)

	runner.run_test("Array has", func():
		var arr = [1, 2, 3, 4, 5]
		return runner.assert_true(arr.has(3))
	)

	runner.run_test("Array find", func():
		var arr = [1, 2, 3, 4, 5]
		return runner.assert_eq(arr.find(3), 2)
	)

	runner.run_test("Clamp float", func():
		var value = 1.5
		var result = clampf(value, 0.0, 1.0)
		return runner.assert_eq(result, 1.0)
	)

	runner.run_test("Maxf", func():
		var a = 5.0
		var b = 10.0
		var result = maxf(a, b)
		return runner.assert_eq(result, 10.0)
	)

	runner.run_test("Minf", func():
		var a = 5.0
		var b = 10.0
		var result = minf(a, b)
		return runner.assert_eq(result, 5.0)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
