extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== Doll3D System Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("Doll3D class exists", func():
		return runner.assert_true(load("res://Visuals/Doll3D.gd") != null)
	)

	runner.run_test("DeformModifier3D class exists", func():
		return runner.assert_true(load("res://Visuals/SkeletonModifiers/DeformModifier3D.gd") != null)
	)

	runner.run_test("JiggleModifier3D class exists", func():
		return runner.assert_true(load("res://Visuals/SkeletonModifiers/JiggleModifier3D.gd") != null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
