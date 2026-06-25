extends NpcOwnerEventBase

var damageTexts:Array = []

func _init():
	id = "Punish1RipsClothes"
	reactsToTags = [E_PUNISH_WEAK]

func getSubEventScore(_event, _tag:String, _args:Array) -> float:
	return 1.0

func trySubEventStart(_event, _tag:String, _args:Array, _context:Dictionary) -> bool:
	var npcOwner := getNpcOwner()
	if(!npcOwner):
		return false
	if(!ServiceLocator.safe_get_service(&"Player").canDamageClothes()):
		return false
	
	for _i in range(randi_range(2, 4)):
		var theResult:Array = ServiceLocator.safe_get_service(&"Player").damageClothes()
		var didDamage:bool = theResult[0]
		if(!didDamage):
			continue
		var damageText:String = theResult[1]
		var damageItem:ItemBase = theResult[2]
		
		if(!damageTexts.is_empty()):
			damageTexts.append(RNG.pick([
				"{npc.name} keeps ripping your clothes!",
				"{npc.name} is still going!",
				"Your owner rips your clothes more and more!",
				"{npc.He} just {npc.verb('refuse')} to stop!",
			]))
		damageTexts.append("Your "+damageItem.getVisibleName()+" got damaged! "+damageText)
		
	return true
	
func start():
	playAnimation(StageScene.Duo, "hurt", {npc=getOwnerID(), npcAction="shove"})
	sayPretext()
	saynn("As a punishment, your owner starts ripping your clothes!")
	for theLine in damageTexts:
		saynn(theLine)
	talkModularOwnerToPC("SoftSlaveryPunishRipClothes")
	saynn("And just like that, the punishment ends.")
	addContinue("endEvent")

func saveData() -> Dictionary:
	var data := super.saveData()
	
	data["damageTexts"] = damageTexts
	
	return data

func loadData(_data:Dictionary):
	super.loadData(_data)
	
	damageTexts = SAVE.loadVar(_data, "damageTexts", [])
