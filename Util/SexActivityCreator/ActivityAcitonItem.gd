extends HBoxContainer

var id = ""
var data = null

signal onEditButton(id, data)
signal onDeleteButton(id, data)
signal onDownButton(id, data)
signal onUpButton(id, data)

func _on_EditButton_pressed():
	onEditButton.emit(id, data)

func _on_DeleteButton_pressed():
	onDeleteButton.emit(id, data)

func _on_DownButton_pressed():
	onDownButton.emit(id, data)

func _on_UpButton_pressed():
	onUpButton.emit(id, data)

func setText(theText):
	$Label.text = theText.replace("\n", " | ")
