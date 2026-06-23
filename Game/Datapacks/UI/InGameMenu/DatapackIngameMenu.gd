extends Control

@onready var entry_list = $VBoxContainer/ScrollContainer/EntryList

var entryScene = preload("res://Game/Datapacks/UI/InGameMenu/DatapackInGameEntry.tscn")
@onready var keep_flags_window_dialog = $VBoxContainer/Label/KeepFlagsWindowDialog
@onready var update_window_dialog = $VBoxContainer/Label/UpdateWindowDialog

signal onClosePressed

func updateList():
	Util.delete_children(entry_list)
	
	for datapackID in GlobalRegistry.getDatapacks():
		var datapack:Datapack = GlobalRegistry.getDatapack(datapackID)
		
		var newEntry = entryScene.instantiate()
		entry_list.add_child(newEntry)
		
		newEntry.setNameLabel(datapack.getFancyName())
		newEntry.setContainsLabel(datapack.getContainsString())
		newEntry.id = datapackID
		
		newEntry.onLoadPressed.connect(onDatapackLoadPressed)
		newEntry.onUnloadPressed.connect(onDatapackUnloadPressed)
		newEntry.onUpdatePressed.connect(onDatapackUpdatePressed)
		
		if(!datapack.needsTogglingOn()):
			newEntry.setNothingToLoad()
			newEntry.setCanUpdate(false)
		else:
			if(GM.main.isDatapackLoaded(datapackID)):
				newEntry.setIsLoaded(true)
				newEntry.setCanUpdate(!datapack.characters.is_empty())
			else:
				newEntry.setIsLoaded(false)
				newEntry.setCanUpdate(false)

func onDatapackLoadPressed(datapackID):
	GM.main.loadDatapackAndDependencies(datapackID)
	updateList()

var datapackIDToUse = null
func onDatapackUnloadPressed(datapackID):
	var datapack:Datapack = GlobalRegistry.getDatapack(datapackID)
	if(datapack != null):
		if(!datapack.flags.is_empty()):
			datapackIDToUse = datapackID
			keep_flags_window_dialog.popup_centered()
			return
	
	GM.main.unloadDatapack(datapackID)
	updateList()

func _on_DatapackIngameMenu_visibility_changed():
	if(visible):
		updateList()

func _on_CloseButton_pressed():
	onClosePressed.emit()

func _on_ClearFlagsButton_pressed():
	if(datapackIDToUse == null):
		return
	
	GM.main.clearDatapackFlags(datapackIDToUse)
	GM.main.unloadDatapack(datapackIDToUse)
	updateList()
	datapackIDToUse = null
	keep_flags_window_dialog.hide()

func _on_KeepFlagsButton_pressed():
	if(datapackIDToUse == null):
		return
	
	GM.main.unloadDatapack(datapackIDToUse)
	updateList()
	datapackIDToUse = null
	keep_flags_window_dialog.hide()

func onDatapackUpdatePressed(_datapackID):
	datapackIDToUse = _datapackID
	update_window_dialog.popup_centered()
	
func _on_UpdateWindowDialog_confirmed():
	if(datapackIDToUse == null):
		return
	
	GM.main.reloadDatapack(datapackIDToUse)
	
	datapackIDToUse = null
