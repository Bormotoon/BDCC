extends Node

func _ready() -> void:
	print("\n" + "=".repeat(50))
	print("BDCC Migration Test Suite")
	print("=".repeat(50))

	var test_paths = [
		"res://Tests/TestHealthComponent.gd",
		"res://Tests/TestBaseCharacter.gd",
		"res://Tests/TestSimulationBridge.gd",
		"res://Tests/TestSexEngine.gd",
		"res://Tests/TestUtil.gd",
		"res://Tests/TestInventory.gd",
		"res://Tests/TestEventBus.gd",
		"res://Tests/TestServiceLocator.gd",
		"res://Tests/TestSaveManager.gd",
		"res://Tests/TestGlobalRegistry.gd",
		"res://Tests/TestSkillsHolder.gd",
		"res://Tests/TestBuffsHolder.gd",
		"res://Tests/TestBodypart.gd",
		"res://Tests/TestPregnancy.gd",
		"res://Tests/TestDoll3D.gd",
		"res://Tests/TestLustCombat.gd",
		"res://Tests/TestCrotchCode.gd",
		"res://Tests/TestModularDialogue.gd",
		"res://Tests/TestServiceArchitecture.gd",
	]

	var total_passed = 0
	var total_failed = 0
	var total_tests = 0

	for test_path in test_paths:
		var test_script = load(test_path)
		if test_script == null:
			print("  ERROR: Could not load " + test_path)
			continue
		var test_instance = test_script.new()
		add_child(test_instance)
		test_instance.run()
		if test_instance.runner != null:
			total_passed += test_instance.runner.tests_passed
			total_failed += test_instance.runner.tests_failed
			total_tests += test_instance.runner.tests_total
		test_instance.queue_free()

	print("\n" + "=".repeat(50))
	print("TOTAL: " + str(total_passed) + "/" + str(total_tests) + " passed")
	if total_failed > 0:
		print("FAILURES: " + str(total_failed))

	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
