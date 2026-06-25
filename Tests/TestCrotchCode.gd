extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== CrotchCode Transpiler Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("CrotchTranspiler class exists", func():
		return runner.assert_true(load("res://Systems/CrotchCode/CrotchTranspiler.gd") != null)
	)

	runner.run_test("CrotchScriptBase class exists", func():
		return runner.assert_true(load("res://Systems/CrotchCode/CrotchScriptBase.gd") != null)
	)

	runner.run_test("CrotchCompiler class exists", func():
		return runner.assert_true(load("res://Systems/CrotchCode/CrotchCompiler.gd") != null)
	)

	runner.run_test("CrotchGraphEditor class exists", func():
		return runner.assert_true(load("res://Systems/CrotchCode/CrotchGraphEditor.gd") != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
