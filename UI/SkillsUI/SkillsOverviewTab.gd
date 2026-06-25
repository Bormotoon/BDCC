extends Control

@onready var skillsContainer = $ScrollContainer/VBoxContainer/SkillsContainer
@onready var basePerksInfo = $ScrollContainer/VBoxContainer/BasePerksInfo
@onready var basePerksLabel = $ScrollContainer/VBoxContainer/BasePerksInfo/BasePerksLabel
var skillOverviewPanelScene = preload("res://UI/SkillsUI/SkillOverviewPanel.tscn")

signal openPerksButton(skillID)
signal openBasePerks

func updateSkills():
	Util.delete_children(skillsContainer)
	
	var skills = ServiceLocator.safe_get_service(&"Player").getSkillsHolder().getSkills()
	for skillID in skills:
		var skillPanel = skillOverviewPanelScene.instantiate()
		skillsContainer.add_child(skillPanel)
		skillPanel.setSkillID(skillID)
		skillPanel.perksButton.connect(onPerksButton)
	
	var basePerksAmount = ServiceLocator.safe_get_service(&"Player").getSkillsHolder().getVisibleBasePerksIDs().size()
	if(basePerksAmount == 0):
		basePerksInfo.visible = false
	else:
		basePerksLabel.text = "You have "+str(basePerksAmount)+" base perk"+("s" if basePerksAmount > 1 else "")
		basePerksInfo.visible = true

func _on_SkillsOverviewTab_visibility_changed():
	if(visible):
		updateSkills()

func onPerksButton(skillID):
	openPerksButton.emit(skillID)

func _on_BasePerksButton_pressed():
	openBasePerks.emit()
