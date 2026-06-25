extends Node

const TestRunnerScript = preload("res://Tests/TestRunner.gd")
var runner

func run() -> void:
	print("\n=== BaseCharacter Formula Tests ===")
	runner = TestRunnerScript.new()
	add_child(runner)

	runner.run_test("Cum inflation threshold 3000", func():
		var total = 2500.0
		var threshold = 3000.0
		var tooMuch = maxf(total - threshold, 0.0)
		return runner.assert_eq(tooMuch, 0.0)
	)

	runner.run_test("Cum inflation above threshold", func():
		var total = 4000.0
		var threshold = 3000.0
		var tooMuch = maxf(total - threshold, 0.0)
		var result = clampf(tooMuch / 2000.0, 0.0, 10.0)
		return runner.assert_near(result, 0.5, 0.01)
	)

	runner.run_test("Cum inflation cap at 10", func():
		var total = 25000.0
		var threshold = 3000.0
		var tooMuch = maxf(total - threshold, 0.0)
		var result = clampf(tooMuch / 2000.0, 0.0, 10.0)
		return runner.assert_eq(result, 10.0)
	)

	runner.run_test("Penetration formula 500/(5+diff)", func():
		var diff = 5.0
		var result = maxf(500.0 / (5.0 + diff), 30.0)
		return runner.assert_near(result, 50.0, 0.01)
	)

	runner.run_test("Penetration floor at 30", func():
		var diff = 100.0
		var result = maxf(500.0 / (5.0 + diff), 30.0)
		return runner.assert_eq(result, 30.0)
	)

	runner.run_test("Birth stretch sqrt(count)*30", func():
		var count = 4.0
		var result = sqrt(count) * 30.0
		return runner.assert_near(result, 60.0, 0.01)
	)

	runner.run_test("Pregnancy kid multiplier pow(kids, 0.25)", func():
		var kids = 16.0
		var result = pow(kids, 0.25)
		return runner.assert_near(result, 2.0, 0.01)
	)

	runner.run_test("Arousal cap at 1000", func():
		var arousal = 900.0
		var add = 200.0
		var result = clampf(arousal + add, 0.0, 1000.0)
		return runner.assert_eq(result, 1000.0)
	)

	runner.run_test("Stamina floor at 0", func():
		var base = -10.0
		var extra = 5.0
		var result = maxf(0.0, base + extra)
		return runner.assert_eq(result, 0.0)
	)

	print("  Results: " + str(runner.tests_passed) + "/" + str(runner.tests_total) + " passed")
