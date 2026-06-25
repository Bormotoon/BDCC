extends SkillBase
			
func _init():
	id = Skill.Hypnosis
	levelChanged.connect(_on_levelChanged)

func getVisibleName():
	return "Hypnosis"

func getVisibleDescription():
	return "Shows the control you display over your own subconscious."

func getPerkTiers():
	return [
		[0],
		[2],
		[5],
	]

func _on_levelChanged(idParam, _levelParam):
	if(id != idParam):
		return
	checkDrawbacks()
		
func checkDrawbacks():
	if(npc == null):
		return
	if(not ServiceLocator.safe_get_service(&"MainScene").getFlag("HypnokinkModule.SoftOptIn", false)):
		return
	if(level >= 1):
		if(!npc.getSkillsHolder().hasPerkDisabledOrNot(Perk.HypnosisKeywordsDrawback)):
			npc.getSkillsHolder().addPerk(Perk.HypnosisKeywordsDrawback)
			flashDrawbackMessage(GlobalRegistry.getPerk(Perk.HypnosisKeywordsDrawback))
	if(level >= 3):
		if(!npc.getSkillsHolder().hasPerkDisabledOrNot(Perk.HypnosisFamousDrawback)):
			npc.getSkillsHolder().addPerk(Perk.HypnosisFamousDrawback)
			flashDrawbackMessage(GlobalRegistry.getPerk(Perk.HypnosisFamousDrawback))
	if(level >= 5):
		if(!npc.getSkillsHolder().hasPerkDisabledOrNot(Perk.HypnosisDeepTranceDrawback)):
			npc.getSkillsHolder().addPerk(Perk.HypnosisDeepTranceDrawback)
			flashDrawbackMessage(GlobalRegistry.getPerk(Perk.HypnosisDeepTranceDrawback))
			
func flashDrawbackMessage(drawbackPerk: PerkBase):
	if(npc != ServiceLocator.safe_get_service(&"Player")):
		return;
	if(ServiceLocator.safe_get_service(&"UI")):
		ServiceLocator.safe_get_service(&"MainScene").addMessage("You have gained a new drawback: "+drawbackPerk.getVisibleName()+"!")
