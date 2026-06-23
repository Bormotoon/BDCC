extends "res://Game/Datapacks/UI/PackVarUIs/PackVarUIBase.gd"
@onready var location_button = $LocationButton

@onready var label = $Label
var location = "main_punishment_spot"
var mapLockerPickerWindowScene = preload("res://Game/Datapacks/UI/CrotchCode/UI/MapLocPickerWindow.tscn")

func setData(_dataLine:Dictionary):
	if(_dataLine.has("name")):
		label.text = _dataLine["name"]
	if(_dataLine.has("value")):
		setLocation(_dataLine["value"])

func setLocation(newLoc):
	location = newLoc
	
	location_button.text = str(location)

func _on_LocationButton_pressed():
	var newWindow = mapLockerPickerWindowScene.instantiate()
	add_child(newWindow)
	newWindow.setSelectedCell(str(location))
	newWindow.onCancelPressed.connect(onMapButtonClosed)
	newWindow.onCellSelected.connect(onMapButtonCellSelected)
	
	newWindow.popup_centered()

func onMapButtonClosed(window):
	window.queue_free()

func onMapButtonCellSelected(window, cell):
	window.queue_free()
	setLocation(cell)
	triggerChange(location)
