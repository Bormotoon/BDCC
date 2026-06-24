extends Object
class_name Log

static func err(text: String):
	printerr(text)

static func error(text: String):
	printerr(text)

static func warning(text: String):
	print_rich("[color=yellow]" + text + "[/color]")

static func msg(text: String):
	print(text)

static func verbose(text: String):
	print(text)
