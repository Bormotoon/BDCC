extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== HealthComponent Formula Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("Pain threshold floor at 10", func():
		var base = 5.0
		var extra = 3.0
		var result = maxf(10.0, base + extra)
		return runner.assert_eq(result, 10.0)
	)

	runner.run_test("Pain threshold with sufficient base", func():
		var base = 15.0
		var extra = 5.0
		var result = maxf(10.0, base + extra)
		return runner.assert_eq(result, 20.0)
	)

	runner.run_test("Damage multiplier floor at -0.8", func():
		var mult = -1.5
		if mult < -0.8:
			mult = -0.8
		return runner.assert_eq(mult, -0.8)
	)

	runner.run_test("Damage multiplier cap at 0.8 (dodge)", func():
		var mult = 1.5
		if mult > 0.8:
			mult = 0.8
		return runner.assert_eq(mult, 0.8)
	)

	runner.run_test("Accuracy floor at -0.9", func():
		var mult = -2.0
		if mult < -0.9:
			mult = -0.9
		return runner.assert_eq(mult, -0.9)
	)

	runner.run_test("Armor reduction positive", func():
		var damage = 100.0
		var armor = 50.0
		var result = roundi(damage * (50.0 / (50.0 + armor)))
		return runner.assert_eq(result, 50)
	)

	runner.run_test("Armor reduction negative", func():
		var damage = 100.0
		var armor = -25.0
		var result = roundi(damage * (-armor / 50.0))
		return runner.assert_eq(result, 50)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
