extends Node

## MIGRATED to Godot 4 (GDScript 2.0).
## Debug console singleton. All Godot 3 patterns fixed.

@onready var control := Control.new()
var consoleScene = preload("res://UI/DebugUI/DebugConsole.tscn")

var commands: Dictionary = {}

signal onConsoleOutput(text: String)

func _ready() -> void:
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 3
	add_child(canvas_layer)
	control.anchor_bottom = 0.9
	control.anchor_right = 1.0
	canvas_layer.add_child(control)
	control.visible = false

	var console = consoleScene.instantiate()
	control.add_child(console)
	onConsoleOutput.connect(console.printLine)
	console.consoleClosed.connect(toggle_console)

	process_mode = Node.PROCESS_MODE_ALWAYS

	printLine("This is a development console")
	add_command("quit", quit)
	add_command("help", help)

func quit() -> void:
	get_tree().quit()

func help() -> void:
	printLine(getCommandsHelp())

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_console"):
		toggle_console()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("close_debug_console") and control.visible:
		toggle_console()
		get_tree().set_input_as_handled()

func toggle_console() -> void:
	control.visible = not control.visible

func add_command(command_name: String, callable: Callable, description: String = "No description provided") -> void:
	commands[command_name] = {
		"callable": callable,
		"description": description,
	}

func remove_command(command_name: String) -> void:
	commands.erase(command_name)

func doTextCommand(command: String) -> void:
	printLine(command)
	var split_text: Array = command.split(" ", true)
	if split_text.size() > 0:
		var command_string: String = split_text[0]
		if commands.has(command_string):
			var command_entry: Dictionary = commands[command_string]
			split_text.pop_front()
			command_entry["callable"].callv(split_text)
		else:
			printLine("Command not found.")

func printLine(text: String) -> void:
	onConsoleOutput.emit(text)

func getCommandsHelp() -> String:
	var result := ""
	for command_name in commands:
		var command: Dictionary = commands[command_name]
		result += command_name + " - " + str(command["description"]) + "\n"
	return result
