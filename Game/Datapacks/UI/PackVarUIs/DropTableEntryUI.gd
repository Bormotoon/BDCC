extends HBoxContainer

var id

signal onDeletePressed(id)

func setData(_data:Dictionary):
	if(_data.has("name")):
		$Label.text = _data["name"]

func _on_DeleteButton_pressed():
	onDeletePressed.emit(id)
