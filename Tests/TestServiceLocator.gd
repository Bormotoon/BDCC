extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== ServiceLocator Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("ServiceLocator is autoloaded", func():
		return runner.assert_true(ServiceLocator != null)
	)

	runner.run_test("ServiceLocator has register_service method", func():
		return runner.assert_true(ServiceLocator.has_method("register_service"))
	)

	runner.run_test("ServiceLocator has get_service method", func():
		return runner.assert_true(ServiceLocator.has_method("get_service"))
	)

	runner.run_test("ServiceLocator has unregister_service method", func():
		return runner.assert_true(ServiceLocator.has_method("unregister_service"))
	)

	runner.run_test("Register and get service", func():
		var test_service = {"name": "test"}
		ServiceLocator.register_service(&"TestService_SL", test_service)
		var result = ServiceLocator.get_service(&"TestService_SL")
		ServiceLocator.unregister_service(&"TestService_SL")
		return runner.assert_eq(result, test_service)
	)

	runner.run_test("Unregister service", func():
		ServiceLocator.register_service(&"TestService2_SL", {"name": "test"})
		ServiceLocator.unregister_service(&"TestService2_SL")
		var has = ServiceLocator._services.has(&"TestService2_SL")
		return runner.assert_false(has)
	)

	runner.run_test("Overwrite service", func():
		ServiceLocator.register_service(&"TestService3_SL", {"name": "first"})
		ServiceLocator.register_service(&"TestService3_SL", {"name": "second"})
		var result = ServiceLocator.get_service(&"TestService3_SL")
		ServiceLocator.unregister_service(&"TestService3_SL")
		return runner.assert_eq(result["name"], "second")
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
