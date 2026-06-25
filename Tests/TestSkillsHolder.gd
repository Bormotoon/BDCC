extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== SkillsHolder Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("SkillsHolder has setStat method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("setStat"))
	)

	runner.run_test("SkillsHolder has getStat method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("getStat"))
	)

	runner.run_test("SkillsHolder has getLevel method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("getLevel"))
	)

	runner.run_test("SkillsHolder has addExperience method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("addExperience"))
	)

	runner.run_test("SkillsHolder has addSkillExperience method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("addSkillExperience"))
	)

	runner.run_test("SkillsHolder has saveData method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("saveData"))
	)

	runner.run_test("SkillsHolder has loadData method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("loadData"))
	)

	runner.run_test("SkillsHolder has getFreeStatPoints method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("getFreeStatPoints"))
	)

	runner.run_test("SkillsHolder has getLevelProgress method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("getLevelProgress"))
	)

	runner.run_test("SkillsHolder has ensureSkillExists method", func():
		var sh = SkillsHolder.new()
		return runner.assert_true(sh.has_method("ensureSkillExists"))
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
