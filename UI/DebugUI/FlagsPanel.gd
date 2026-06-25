extends Control

var flagPanelEntryScene = preload("res://UI/DebugUI/FlagPanelEntry.tscn")
var flagPanelDividerScene = preload("res://UI/DebugUI/FlagPanelDivider.tscn")
@onready var flagEditWindow = $FlagEditWindow
@onready var filterEdit = $ScrollContainer/VBoxContainer/HBoxContainer/LineEdit

@export var addGameFlags = true
@export var addDatapackFlags = false

func updateFlags():
	var filterText = filterEdit.text.to_lower()
	Util.delete_children($ScrollContainer/VBoxContainer/VBoxContainer)
	
	if(ServiceLocator.safe_get_service(&"MainScene") == null):
		return
	
	if(addGameFlags):
		addDivider("GLOBAL FLAGS")
		var flags = ServiceLocator.safe_get_service(&"MainScene").flagsCache
		for flagID in flags:
			if(filterText != "" && !(filterText in flagID.to_lower())):
				continue
			
			var flagData = flags[flagID]
			var flagType = flagData["type"]
			var flagValue = ServiceLocator.safe_get_service(&"MainScene").getFlag(flagID)
			
			var newflagpanelentry = flagPanelEntryScene.instantiate()
			$ScrollContainer/VBoxContainer/VBoxContainer.add_child(newflagpanelentry)
			newflagpanelentry.setNameAndValue(flagID+" ("+str(FlagType.getVisibleName(flagType))+")", flagValue)
			newflagpanelentry.flagID = flagID
			var _ok = newflagpanelentry.changeFlagButton.connect(onFlagChangeButton)

		var modules = GlobalRegistry.getModules()
		for moduleID in modules:
			var module:Module = modules[moduleID]
			
			var modflags = module.getFlagsCache() 
			if(modflags.is_empty()):
				continue
			addDivider(str(moduleID)+" MODULE FLAGS")
			
			
			for flagID in modflags:
				if(filterText != "" && !(filterText in flagID.to_lower())):
					continue
				
				var flagData = modflags[flagID]
				var flagType = flagData["type"]
				var flagValue = ServiceLocator.safe_get_service(&"MainScene").getModuleFlag(moduleID, flagID)
				
				var newflagpanelentry = flagPanelEntryScene.instantiate()
				$ScrollContainer/VBoxContainer/VBoxContainer.add_child(newflagpanelentry)
				newflagpanelentry.setNameAndValue(flagID+" ("+str(FlagType.getVisibleName(flagType))+")", flagValue)
				newflagpanelentry.flagID = flagID
				newflagpanelentry.moduleID = moduleID
				var _ok = newflagpanelentry.changeFlagButton.connect(onFlagChangeButton)
	
	if(addDatapackFlags):
		var loadedDatapacks = ServiceLocator.safe_get_service(&"MainScene").loadedDatapacks
		for datapackID in loadedDatapacks:
			var datapack = GlobalRegistry.getDatapack(datapackID)
			if(datapack == null || datapack.flags.is_empty()):
				continue
			addDivider(str(datapackID)+" DATAPACK FLAGS")
	
			for flagID in datapack.flags:
				if(filterText != "" && !(filterText in flagID.to_lower())):
					continue
				
				var flagData = datapack.flags[flagID]
				var flagType = flagData["type"]
				var flagValue = ServiceLocator.safe_get_service(&"MainScene").getDatapackFlag(datapackID, flagID)
				
				var newflagpanelentry = flagPanelEntryScene.instantiate()
				$ScrollContainer/VBoxContainer/VBoxContainer.add_child(newflagpanelentry)
				newflagpanelentry.setNameAndValue(flagID+" ("+str(DatapackSceneVarType.getName(flagType))+")", flagValue)
				newflagpanelentry.flagID = flagID
				newflagpanelentry.moduleID = datapackID
				var _ok = newflagpanelentry.changeFlagButton.connect(onDatapackFlagChangeButton)
	
	
func addDivider(text):
	var flagPanelDividerObject = flagPanelDividerScene.instantiate()
	$ScrollContainer/VBoxContainer/VBoxContainer.add_child(flagPanelDividerObject)
	flagPanelDividerObject.setText(text)


func _on_Button_pressed():
	updateFlags()


func _on_FlagsPanel_visibility_changed():
	if(visible):
		updateFlags()

func onFlagChangeButton(moduleID, flagID):
	flagEditWindow.setFlag(moduleID, flagID)
	flagEditWindow.popup_centered()

func onDatapackFlagChangeButton(moduleID, flagID):
	flagEditWindow.setDatpackFlag(moduleID, flagID)
	flagEditWindow.popup_centered()


func _on_FlagEditWindow_clearFlag(moduleID, flagID):
	if(moduleID == null || moduleID == ""):
		ServiceLocator.safe_get_service(&"MainScene").clearFlag(flagID)
		Log.msg("Cleared flag "+str(flagID))
	else:
		ServiceLocator.safe_get_service(&"MainScene").clearModuleFlag(moduleID, flagID)
		Log.msg("Cleared flag "+str(flagID)+" in module "+str(moduleID))
	updateFlags()

func _on_FlagEditWindow_setFlagValue(moduleID, flagID, value):
	if(moduleID == null || moduleID == ""):
		ServiceLocator.safe_get_service(&"MainScene").setFlag(flagID, value)
		Log.msg("Setting flag "+str(flagID)+" to "+str(value))
	else:
		ServiceLocator.safe_get_service(&"MainScene").setModuleFlag(moduleID, flagID, value)
		Log.msg("Setting flag "+str(flagID)+" in module "+str(moduleID)+" to "+str(value))
	updateFlags()


func _on_LineEdit_text_entered(_new_text):
	updateFlags()


func _on_FlagEditWindow_setDatapackFlagValue(moduleID, flagID, value):
	ServiceLocator.safe_get_service(&"MainScene").setDatapackFlag(moduleID, flagID, value)
	Log.msg("Setting datapack flag "+str(flagID)+" in datapack "+str(moduleID)+" to "+str(value))
	updateFlags()

func _on_FlagEditWindow_clearDatapackFlag(moduleID, flagID):
	ServiceLocator.safe_get_service(&"MainScene").clearDatapackFlag(moduleID, flagID)
	Log.msg("Cleared flag "+str(flagID)+" in datapack "+str(moduleID))
	updateFlags()
