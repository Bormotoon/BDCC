extends Control

var saveGameElemenetScene = preload("res://UI/MainMenu/SaveGameElement.tscn")
@onready var saves_container = $SavesContainer

signal onSavePicked(path)
signal onClosePressed

func _ready():
	updateSaves()

func updateSaves():
	Util.delete_children(saves_container)
	
	var savesPaths = SAVE.getSavesSortedByDate()
	
	for savePath in savesPaths:
		var saveGameElementObject = saveGameElemenetScene.instantiate()
		saves_container.add_child(saveGameElementObject)
		saveGameElementObject.setSaveFile(savePath)
		saveGameElementObject.onLoadButtonPressed.connect(onSaveLoadButtonClicked)
		saveGameElementObject.setDeleteMode(false)
		saveGameElementObject.setPickMode()

func onSaveLoadButtonClicked(savePath):
	onSavePicked.emit(savePath)

func _on_BackButton_pressed():
	onClosePressed.emit()
