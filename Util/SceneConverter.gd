extends Control

## MIGRATED to Godot 4 (GDScript 2.0).
## Scene converter from Google Docs to code.

@onready var input_text_edit: TextEdit = $VBoxContainer/TextEdit
@onready var output_text_edit: TextEdit = $VBoxContainer/TextEdit2

func _ready() -> void:
	$VBoxContainer/TextEdit2.add_color_region("#", "", Color.CADET_BLUE)

func _on_Button_pressed() -> void:
	var result := ""
	var text := input_text_edit.text
	var lines := text.split("\n")
	result += "\t" + "if(state == \"\"):\n"

	for line in lines:
		var textline: String = line
		textline = textline.trim_prefix(" ").trim_suffix(" ")
		if textline.is_empty():
			continue
		if textline.begins_with(">"):
			textline = textline.substr(1).trim_prefix(" ")
			var first_comma := textline.find(",")
			var button_text := ""
			if first_comma >= 0:
				button_text = textline.substr(0, first_comma).trim_prefix(" ").trim_suffix(" ")
			else:
				button_text = textline
			var key := button_text.to_lower().replace(" ", "_")
			result += "\t\taddButton(\"" + button_text + "\")\n"
		else:
			result += "\t\tsaynn(\"" + textline.replace("\"", "\\\"") + "\")\n"

	output_text_edit.text = result
