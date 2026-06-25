extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== ModularDialogue Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("ModularDialogue class exists", func():
		return runner.assert_true(load("res://Game/ModularDialogue/ModularDialogue.gd") != null)
	)

	runner.run_test("DialogueForm class exists", func():
		return runner.assert_true(load("res://Game/ModularDialogue/DialogueForm.gd") != null)
	)

	runner.run_test("DialogueFiller class exists", func():
		return runner.assert_true(load("res://Game/ModularDialogue/DialogueFiller.gd") != null)
	)

	runner.run_test("DialogueParser class exists", func():
		return runner.assert_true(load("res://Game/ModularDialogue/Parser/DialogueParser.gd") != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
