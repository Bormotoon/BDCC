extends MathLogicBiggerThan
class_name MathLogicNotEquals

func getCategories():
	return ["Math", "Logic"]

func thingOnlyNumbers():
	return false

func checkThing(a, b):
	return a != b

func getThingLabel():
	return "!="
