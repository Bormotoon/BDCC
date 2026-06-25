extends Control


func updateBuffsText():
	var newtext = "Your current buffs/debuffs are displayed here\n\n"
	if(ServiceLocator.safe_get_service(&"MainScene") == null || ServiceLocator.safe_get_service(&"Player") == null):
		return
	
	var items = ServiceLocator.safe_get_service(&"Player").getInventory().getAllEquippedItems()
	for slot in items:
		var item = items[slot]
		var itemBuffs = item.getBuffs()
		if(itemBuffs != null && itemBuffs is Array && itemBuffs.size() > 0):
			newtext += item.getVisibleName()+" equipped item:\n"
			
			for buff in itemBuffs:
				newtext += buff.getVisibleDescriptionColored()+"\n"
			newtext += "\n"
		
		
	var statusEffects = ServiceLocator.safe_get_service(&"Player").getStatusEffects()
	for statusEffectID in statusEffects:
		var statusEffect = statusEffects[statusEffectID]
		var statusEffectBuffs = statusEffect.getBuffs()
		if(statusEffectBuffs != null && statusEffectBuffs is Array && statusEffectBuffs.size() > 0):
			newtext += statusEffect.getEffectName()+" status effect:\n"
			
			for buff in statusEffectBuffs:
				newtext += buff.getVisibleDescriptionColored()+"\n"
			newtext += "\n"

	var perks = ServiceLocator.safe_get_service(&"Player").getSkillsHolder().getPerks()
	for perkID in perks:
		var perk = perks[perkID]
		var perkBuffs = perk.getBuffs()
	
		if(perkBuffs != null && perkBuffs is Array && perkBuffs.size() > 0):
			newtext += perk.getVisibleName()+" perk:\n"
			
			for buff in perkBuffs:
				newtext += buff.getVisibleDescriptionColored()+"\n"
			newtext += "\n"
	
	$ScrollContainer/VBoxContainer/RichTextLabel.text = newtext
	

func _on_BuffsScreen_visibility_changed():
	if(visible):
		updateBuffsText()
