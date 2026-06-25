extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== BuffsHolder Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("BuffsHolder has calculateBuffs method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("calculateBuffs"))
	)

	runner.run_test("BuffsHolder has addCustom method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("addCustom"))
	)

	runner.run_test("BuffsHolder has getCustom method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("getCustom"))
	)

	runner.run_test("BuffsHolder has getDealDamageMult method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("getDealDamageMult"))
	)

	runner.run_test("BuffsHolder has getRecieveDamageMult method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("getRecieveDamageMult"))
	)

	runner.run_test("BuffsHolder has getArmor method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("getArmor"))
	)

	runner.run_test("BuffsHolder has getDodgeChance method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("getDodgeChance"))
	)

	runner.run_test("BuffsHolder has getAccuracy method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("getAccuracy"))
	)

	runner.run_test("BuffsHolder has getExtraPainThreshold method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("getExtraPainThreshold"))
	)

	runner.run_test("BuffsHolder has getExtraStamina method", func():
		var bh = BuffsHolder.new()
		return runner.assert_true(bh.has_method("getExtraStamina"))
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
