extends PanelContainer

var storedEntry = null

signal onSelected(modEntry)

func setModEntry(modEntry:ModEntry):
	$HBoxContainer/Label.text = modEntry.name+" [by "+modEntry.author+"]"
	storedEntry = modEntry

func _on_TextureButton_pressed():
	onSelected.emit(storedEntry)

func makeActive():
	$Panel.visible = true

func makeInactive():
	$Panel.visible = false
