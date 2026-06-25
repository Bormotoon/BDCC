extends WindowDialog

var moduleID
var datapackID
var flagID
var savedFlagType

signal clearFlag(moduleID, flagID)
signal clearDatapackFlag(moduleID, flagID)
signal setFlagValue(moduleID, flagID, value)
signal setDatapackFlagValue(moduleID, flagID, value)

@onready var checkbox = $VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainer/CheckBox
@onready var spinbox = $VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainer/SpinBox
@onready var lineedit = $VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainer/LineEdit

func setDatpackFlag(newdatpackid, newflagID):
	datapackID = newdatpackid
	moduleID = null
	flagID = newflagID
	
	checkbox.visible = false
	spinbox.visible = false
	lineedit.visible = false
	
	var flagType = null
	var flagValue = null
	savedFlagType = null
	var datapacks = GlobalRegistry.getDatapacks()
	if(datapacks.has(datapackID)):
		var datapack:Datapack = datapacks[datapackID]
		
		var cashedFlags = datapack.flags
		if(cashedFlags.has(flagID)):
			var flagData = cashedFlags[flagID]
			flagType = flagData["type"]
			flagValue = ServiceLocator.safe_get_service(&"MainScene").getDatapackFlag(datapackID, flagID)
			
			$VBoxContainer/ScrollContainer/VBoxContainer/FlagLabel.text = str(flagID)+" ("+DatapackSceneVarType.getName(flagType)+")"

	$VBoxContainer/ScrollContainer/VBoxContainer/CurrentValueLabel.text = "Current value: "+str(flagValue)
	savedFlagType = flagType
	
	if(flagType == DatapackSceneVarType.BOOL):
		checkbox.visible = true
		
		if(flagValue != null):
			checkbox.pressed = !!flagValue
		else:
			checkbox.pressed = false
		
	if(flagType == DatapackSceneVarType.NUMBER):
		spinbox.visible = true
		
		if(flagValue != null):
			spinbox.value = flagValue
		else:
			spinbox.value = 0

	if(flagType == DatapackSceneVarType.STRING):
		lineedit.visible = true
		
		if(flagValue != null):
			lineedit.text = str(flagValue)
		else:
			lineedit.text = ""

func setFlag(newmoduleID, newflagID):
	datapackID = null
	moduleID = newmoduleID
	flagID = newflagID
	
	checkbox.visible = false
	spinbox.visible = false
	lineedit.visible = false
	
	var flagType = null
	var flagValue = null
	savedFlagType = null
	if(moduleID == null || moduleID == ""):
		if(ServiceLocator.safe_get_service(&"MainScene").flagsCache.has(flagID)):
			var flagData = ServiceLocator.safe_get_service(&"MainScene").flagsCache[flagID]
			flagType = flagData["type"]
			flagValue = ServiceLocator.safe_get_service(&"MainScene").getFlag(flagID)
			
			$VBoxContainer/ScrollContainer/VBoxContainer/FlagLabel.text = str(flagID)+" ("+FlagType.getVisibleName(flagType)+")"
			
	else:
		var modules = GlobalRegistry.getModules()
		if(modules.has(moduleID)):
			var module:Module = modules[moduleID]
			
			var cashedFlags = module.getFlagsCache()
			if(cashedFlags.has(flagID)):
				var flagData = cashedFlags[flagID]
				flagType = flagData["type"]
				flagValue = ServiceLocator.safe_get_service(&"MainScene").getModuleFlag(newmoduleID, flagID)
				
				$VBoxContainer/ScrollContainer/VBoxContainer/FlagLabel.text = str(flagID)+" ("+FlagType.getVisibleName(flagType)+")"

	$VBoxContainer/ScrollContainer/VBoxContainer/CurrentValueLabel.text = "Current value: "+str(flagValue)
	savedFlagType = flagType
	
	if(flagType == FlagType.Bool):
		checkbox.visible = true
		
		if(flagValue != null):
			checkbox.pressed = !!flagValue
		else:
			checkbox.pressed = false
		
	if(flagType == FlagType.Number):
		spinbox.visible = true
		
		if(flagValue != null):
			spinbox.value = flagValue
		else:
			spinbox.value = 0

	if(flagType == FlagType.Text):
		lineedit.visible = true
		
		if(flagValue != null):
			lineedit.text = str(flagValue)
		else:
			lineedit.text = ""


func _on_CancelButton_pressed():
	visible = false

func _on_ClearFlag_pressed():
	if(datapackID != null):
		clearDatapackFlag.emit(datapackID, flagID)
	else:
		clearFlag.emit(moduleID, flagID)
	visible = false

func _on_ChangeFlagButton_pressed():
	if(datapackID != null):
		if(savedFlagType == DatapackSceneVarType.BOOL):
			setDatapackFlagValue.emit(datapackID, flagID, checkbox.pressed)
		if(savedFlagType == DatapackSceneVarType.STRING):
			setDatapackFlagValue.emit(datapackID, flagID, lineedit.text)
		if(savedFlagType == DatapackSceneVarType.NUMBER):
			setDatapackFlagValue.emit(datapackID, flagID, spinbox.value)
	else:
		if(savedFlagType == FlagType.Bool):
			setFlagValue.emit(moduleID, flagID, checkbox.pressed)
		if(savedFlagType == FlagType.Text):
			setFlagValue.emit(moduleID, flagID, lineedit.text)
		if(savedFlagType == FlagType.Number):
			setFlagValue.emit(moduleID, flagID, spinbox.value)
	visible = false
