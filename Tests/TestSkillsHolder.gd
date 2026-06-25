extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== SkillsHolder Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("SkillsHolder class exists", func():
		return runner.assert_true(load("res://Skills/SkillsHolder.gd") != null)
	)

	runner.run_test("SkillBase class exists", func():
		return runner.assert_true(load("res://Skills/SkillBase.gd") != null)
	)

	runner.run_test("PerkBase class exists", func():
		return runner.assert_true(load("res://Skills/PerkBase.gd") != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
