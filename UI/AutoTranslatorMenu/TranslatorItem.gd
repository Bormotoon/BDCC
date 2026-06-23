extends HBoxContainer

var id = ""
var data = null

signal onDownButton(id, data)
signal onUpButton(id, data)

func _on_DownButton_pressed():
	onDownButton.emit(id, data)

func _on_UpButton_pressed():
	onUpButton.emit(id, data)

func setText(theText):
	$Label.text = theText.replace("\n", " | ")
