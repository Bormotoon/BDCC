extends VBoxContainer

@export var addSeparators = true
signal onVariableChange(id, value)

var collapseRegionScene = preload("res://Game/Datapacks/UI/PackVarsCollapsableRegion.tscn")

var widgets = []
var collapsers = []

func setVariables(_data:Dictionary):
	Util.delete_children(self)
	widgets = []
	collapsers = []
	
	for dataID in _data:
		var dataLine = _data[dataID]
		
		var type = dataLine["type"]
		
		var newWidget
		
		if(type == "string"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/StringVarUI.tscn").instantiate()
		elif(type == "bigString"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/BigStringVarUI.tscn").instantiate()
		elif(type == "editor"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/EditorVarUI.tscn").instantiate()
		elif(type == "bodyparts"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/BodypartsVarUI.tscn").instantiate()
		elif(type == "bodypart"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/BodypartSingleVarUI.tscn").instantiate()
		elif(type == "skin"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/SkinVarUI.tscn").instantiate()
		elif(type == "number"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/NumberVarUI.tscn").instantiate()
		elif(type == "selector"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/SelectorVarUI.tscn").instantiate()
		elif(type == "equippedItems"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/EquippedItemsVarUI.tscn").instantiate()
		elif(type == "equippedItem"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/EquipItemVarUI.tscn").instantiate()
		elif(type == "addRemoveList"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/AddRemoveListVarUI.tscn").instantiate()
		elif(type == "color"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/ColorVarUI.tscn").instantiate()
		elif(type == "checkbox"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/CheckboxVarUI.tscn").instantiate()
		elif(type == "personality"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/PersonalityVarUI.tscn").instantiate()
		elif(type == "personalityStat"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/PersonalityStatVarUI.tscn").instantiate()
		elif(type == "fetishes"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/FetishMapVarUI.tscn").instantiate()
		elif(type == "fetishSingle"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/FetishSingleVarUI.tscn").instantiate()
		elif(type == "likesDislikes"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/LikesDislikesMapVarUI.tscn").instantiate()
		elif(type == "likesDislikesSingle"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/LikesDislikesSingleVarUI.tscn").instantiate()
		elif(type == "stats"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/StatsVarUI.tscn").instantiate()
		elif(type == "statSingle"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/StatSingleVarUI.tscn").instantiate()
		elif(type == "image"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/ImageVarUI.tscn").instantiate()
		elif(type == "skinTypeWeights"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/SkinTypeWeightsVarUI.tscn").instantiate()
		elif(type == "lootTable"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/DropTableVarUI.tscn").instantiate()
		elif(type == "location"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/LocationVarUI.tscn").instantiate()
		elif(type == "advancedSelector"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/AdvancedSelectorVarUI.tscn").instantiate()
		elif(type == "autoSelector"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/AutoSelectorVarUI.tscn").instantiate()
		elif(type == "stringID"):
			newWidget = preload("res://Game/Datapacks/UI/PackVarUIs/StringVarIDUI.tscn").instantiate()
		else:
			Log.err("Unknown var type found: "+str(type))

		if(newWidget != null):
			if(dataLine.has("collapsable") && dataLine["collapsable"]):
				var newCollapse = collapseRegionScene.instantiate()
				add_child(newCollapse)
				newCollapse.setText(dataLine["name"] if dataLine.has("name") else dataID)
				newCollapse.addToRegion(newWidget)
				collapsers.append(newCollapse)
			elif(dataLine.has("addtoprev") && dataLine["addtoprev"]):
				collapsers.back().addToRegion(newWidget)
			else:
				add_child(newWidget)
			widgets.append(newWidget)
			newWidget.id = dataID
			newWidget.onValueChange.connect(onWidgetValueChange)
			newWidget.setData(dataLine)
			
			if(addSeparators):
				if(dataLine.has("noseparator") && dataLine["noseparator"]):
					continue
				if(dataLine.has("addtoprev") && dataLine["addtoprev"]):
					collapsers.back().addToRegion(HSeparator.new())
				else:
					add_child(HSeparator.new())

func onWidgetValueChange(id, value):
	onVariableChange.emit(id, value)

func checkWidgetsFinished():
	for widget in widgets:
		widget.onEditorClose()
	return true
