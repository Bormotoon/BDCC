extends SceneTree

func _init() -> void:
	print("\n" + "=".repeat(50))
	print("BDCC Migration Test Suite")
	print("=".repeat(50))

	var test_scripts = [
		preload("res://Tests/TestHealthComponent.gd"),
		preload("res://Tests/TestBaseCharacter.gd"),
		preload("res://Tests/TestSimulationBridge.gd"),
		preload("res://Tests/TestSexEngine.gd"),
		preload("res://Tests/TestUtil.gd"),
	]

	var total_passed = 0
	var total_failed = 0
	var total_tests = 0

	for test_script in test_scripts:
		var test_instance = test_script.new()
		var runner = preload("res://Tests/TestRunner.gd").new()
		test_instance.add_child(runner)
		test_instance.run()
		total_passed += runner.tests_passed
		total_failed += runner.tests_failed
		total_tests += runner.tests_total
		runner.queue_free()

	print("\n" + "=".repeat(50))
	print("TOTAL: " + str(total_passed) + "/" + str(total_tests) + " passed")
	if total_failed > 0:
		print("FAILURES: " + str(total_failed))
		quit(1)
	else:
		print("ALL TESTS PASSED!")
		quit(0)
