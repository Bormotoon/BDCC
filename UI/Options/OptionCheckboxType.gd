extends HBoxContainer

signal value_changed(categoryID, id, newvalue)

var id
var categoryID
var description

func setOptionName(newname):
	$Label.text = newname

func getOptionName():
	return $Label.text

func setOptionValue(_newvalue):
	$Checkbox.pressed = _newvalue

func _on_Checkbox_toggled(button_pressed):
	value_changed.emit(categoryID, id, button_pressed)

func setDescription(newdesc):
	description = newdesc

func getDescription():
	return description
