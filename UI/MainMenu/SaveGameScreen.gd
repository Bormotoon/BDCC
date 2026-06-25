extends Control

@onready var savesContainer = $VBoxContainer/ScrollContainer/ScrollVBox/SavesContainer
@onready var saveFileNameInput = $VBoxContainer/ScrollContainer/ScrollVBox/HBoxContainer/SaveFileNameInput
var saveGameElemenetScene = preload("res://UI/MainMenu/SaveGameElement.tscn")
signal onClosePressed
var inDeleteMode = false

func _ready():
	updateSaves()

func updateSaves():
	Util.delete_children(savesContainer)
	
	var savesPaths = SAVE.getSavesSortedByDate()
	
	for savePath in savesPaths:
		var saveGameElementObject = saveGameElemenetScene.instantiate()
		savesContainer.add_child(saveGameElementObject)
		saveGameElementObject.setSaveFile(savePath)
		saveGameElementObject.onLoadButtonPressed.connect(onSaveLoadButtonClicked)
		saveGameElementObject.onDeleteButtonPressed.connect(onDeleteButtonClicked)
		saveGameElementObject.setDeleteMode(inDeleteMode)
		saveGameElementObject.setShowLoadButton(false)
		
func onSaveLoadButtonClicked(savePath):
	SAVE.switchToGameAndLoad(savePath)

func onDeleteButtonClicked(savePath):
	SAVE.deleteSave(savePath)
	updateSaves()

func _on_CloseButton_pressed():
	onClosePressed.emit()


func _on_LoadGameScreen_visibility_changed():
	if(visible):
		updateSaves()
		
		if(ServiceLocator.safe_get_service(&"UI") != null && ServiceLocator.safe_get_service(&"Player") != null):
			saveFileNameInput.text = Util.stripBadFilenameCharacters(ServiceLocator.safe_get_service(&"Player").getName() + " - Save " + str(GlobalRegistry.currentSave) + " - " + ServiceLocator.safe_get_service(&"UI").getCurrentLocationName())
		else:
			saveFileNameInput.text = "Unknown location"


func _on_DeleteButton_pressed():
	inDeleteMode = !inDeleteMode
	updateSaves()


func _on_SaveButton_pressed():
	var saveName = saveFileNameInput.text
	SAVE.saveGameRelative(saveName)
	updateSaves()


func _on_SaveFileNameInput_text_changed(new_text):
	var old_caret_position = saveFileNameInput.caret_position
	saveFileNameInput.text = Util.stripBadFilenameCharacters(new_text)
	saveFileNameInput.caret_position = old_caret_position
