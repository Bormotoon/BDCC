extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")

func run() -> void:
	print("\n=== Inventory System Tests ===")
	var runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("Inventory initializes empty", func():
		var inv = Inventory.new()
		inv._ready()
		return runner.assert_eq(inv.items.size(), 0)
	)

	runner.run_test("Inventory has add_item method", func():
		var inv = Inventory.new()
		return runner.assert_true(inv.has_method("add_item"))
	)

	runner.run_test("Inventory has has_item method", func():
		var inv = Inventory.new()
		return runner.assert_true(inv.has_method("has_item"))
	)

	runner.run_test("Inventory has get_items method", func():
		var inv = Inventory.new()
		return runner.assert_true(inv.has_method("get_items"))
	)

	runner.run_test("Inventory has save_data method", func():
		var inv = Inventory.new()
		return runner.assert_true(inv.has_method("save_data"))
	)

	runner.run_test("Inventory has load_data method", func():
		var inv = Inventory.new()
		return runner.assert_true(inv.has_method("load_data"))
	)

	runner.run_test("Get equipped items empty", func():
		var inv = Inventory.new()
		inv._ready()
		var equipped = inv.get_equipped_items()
		return runner.assert_eq(equipped.size(), 0)
	)

	runner.run_test("Get all items empty", func():
		var inv = Inventory.new()
		inv._ready()
		var items = inv.get_items()
		return runner.assert_eq(items.size(), 0)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
	runner.queue_free()
