extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== GlobalRegistry Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("GlobalRegistry has mod support function", func():
		return runner.assert_true(GlobalRegistry.has_method("hasModSupport"))
	)

	runner.run_test("GlobalRegistry has getLoadedMods function", func():
		return runner.assert_true(GlobalRegistry.has_method("getLoadedMods"))
	)

	runner.run_test("GlobalRegistry has getModsFolder function", func():
		return runner.assert_true(GlobalRegistry.has_method("getModsFolder"))
	)

	runner.run_test("GlobalRegistry has getDatapacksFolder function", func():
		return runner.assert_true(GlobalRegistry.has_method("getDatapacksFolder"))
	)

	runner.run_test("GlobalRegistry has registerEverything function", func():
		return runner.assert_true(GlobalRegistry.has_method("registerEverything"))
	)

	runner.run_test("GlobalRegistry has generateUniqueID function", func():
		return runner.assert_true(GlobalRegistry.has_method("generateUniqueID"))
	)

	runner.run_test("GlobalRegistry has generateNPCUniqueID function", func():
		return runner.assert_true(GlobalRegistry.has_method("generateNPCUniqueID"))
	)

	runner.run_test("GlobalRegistry has isCacheEnabled function", func():
		return runner.assert_true(GlobalRegistry.has_method("isCacheEnabled"))
	)

	runner.run_test("GlobalRegistry has getGameVersionString function", func():
		return runner.assert_true(GlobalRegistry.has_method("getGameVersionString"))
	)

	runner.run_test("GlobalRegistry getGameVersionString returns string", func():
		var result = GlobalRegistry.getGameVersionString()
		return runner.assert_true(typeof(result) == TYPE_STRING)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
