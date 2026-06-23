extends ScrollContainer

signal onConfirm(selectedStat, selectedPerk)

var statToButton:Dictionary = {}
var perkToButton:Dictionary = {}

var perkList:Array = []

@onready var stat_list = $"%StatList"
@onready var perk_list = $"%PerkList"
@onready var level_label = $"%LevelLabel"
@onready var perks_panel = $"%PerksPanel"


var perkButtonScene = preload("res://UI/SkillsUI/PerkButton.tscn")

var selectedStat:String = ""
var selectedPerk:String = ""

func setData(theLevel:int, thePerkList:Array = [], lastSelectedStat:String = ""):
	statToButton = {}
	perkToButton = {}
	level_label.text = "You have reached level "+str(theLevel)+"!"
	
	selectedStat = lastSelectedStat
	perkList = thePerkList
	
	Util.delete_children(stat_list)
	
	var nothingButton:Button = Button.new()
	stat_list.add_child(nothingButton)
	nothingButton.text = "SKIP"
	statToButton["SKIP"] = nothingButton
	nothingButton.pressed.connect(onStatButtonPressed.bind([""]))

	for statID in GlobalRegistry.getStats():
		var theStat:StatBase = GlobalRegistry.getStat(statID)
		
		var statButton:Button = Button.new()
		stat_list.add_child(statButton)
		statButton.text = theStat.getVisibleName()
		statButton.hint_tooltip = theStat.getVisibleDescription()
		statToButton[statID] = statButton
		statButton.pressed.connect(onStatButtonPressed.bind([statID]))
	
	updateSelectedStatButton()
	
	perks_panel.visible = !perkList.is_empty()
	Util.delete_children(perk_list)
	
	if(!perkList.is_empty()):
		var skipPerkButton = perkButtonScene.instantiate()
		perk_list.add_child(skipPerkButton)
		skipPerkButton.setSkippedPerk()
		perkToButton["SKIP"] = skipPerkButton
		skipPerkButton.perkClicked.connect(onPerkButtonPressed)
		
		for perkID in perkList:
			var perkButton = perkButtonScene.instantiate()
			perk_list.add_child(perkButton)
			perkButton.setPerk(GlobalRegistry.getPerk(perkID), false)
			perkToButton[perkID] = perkButton
			perkButton.perkClicked.connect(onPerkButtonPressed)
	
		updateSelectedPerkButton()

func updateSelectedPerkButton():
	var selectedPerkButtonID:String = "SKIP" if selectedPerk == "" else selectedPerk
	
	for perkID in perkToButton:
		var theButton = perkToButton[perkID]
		var isSelected:bool = (selectedPerkButtonID == perkID)
		theButton.modulate = Color(0.5, 0.5, 0.5) if !isSelected else Color.green

func onPerkButtonPressed(perkID:String):
	selectedPerk = perkID
	updateSelectedPerkButton()

func onStatButtonPressed(statID:String):
	selectedStat = statID
	updateSelectedStatButton()

func updateSelectedStatButton():
	var selectedStatButtonID:String = "SKIP" if selectedStat == "" else selectedStat
	
	for statID in statToButton:
		var theButton:Button = statToButton[statID]
		var isSelected:bool = (selectedStatButtonID == statID)
		var buttonName:String = "SKIP"
		if(statID != "SKIP"):
			var theStat:StatBase = GlobalRegistry.getStat(statID)
			buttonName = theStat.getVisibleName()
			buttonName += " ("+str(GM.pc.getStat(statID))+")"
		
		theButton.text = ("[ "+buttonName+" ]" if isSelected else buttonName)
		theButton.disabled = isSelected
		

func _on_ContinueButton_pressed():
	onConfirm.emit(selectedStat, selectedPerk)
