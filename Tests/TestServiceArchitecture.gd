extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== Service Architecture Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("ServiceLocator has has_service method", func():
		return runner.assert_true(ServiceLocator.has_method("has_service"))
	)

	runner.run_test("ServiceLocator has safe_get_service method", func():
		return runner.assert_true(ServiceLocator.has_method("safe_get_service"))
	)

	runner.run_test("has_service returns false for unregistered", func():
		return runner.assert_false(ServiceLocator.has_service(&"NonExistentService_Test"))
	)

	runner.run_test("safe_get_service returns null for unregistered", func():
		var result = ServiceLocator.safe_get_service(&"NonExistentService_Test")
		return runner.assert_eq(result, null)
	)

	runner.run_test("safe_get_service returns registered service", func():
		var test_obj = {"name": "test_arch"}
		ServiceLocator.register_service(&"TestArchService", test_obj)
		var result = ServiceLocator.safe_get_service(&"TestArchService")
		ServiceLocator.unregister_service(&"TestArchService")
		return runner.assert_eq(result, test_obj)
	)

	runner.run_test("has_service returns true after register", func():
		ServiceLocator.register_service(&"TestArchService2", "value")
		var has = ServiceLocator.has_service(&"TestArchService2")
		ServiceLocator.unregister_service(&"TestArchService2")
		return runner.assert_true(has)
	)

	runner.run_test("safe_get_service returns null after unregister", func():
		ServiceLocator.register_service(&"TestArchService3", "value")
		ServiceLocator.unregister_service(&"TestArchService3")
		var result = ServiceLocator.safe_get_service(&"TestArchService3")
		return runner.assert_eq(result, null)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
