extends SceneBase

var breastsMilked = false
var penisMilked = false
var vaginaMilked = false
var hasPenisPump = false
var amountCollected = 0.0

func _init():
	sceneID = "ElizaQuickMilkingScene"

func _reactInit():
	processTime(30*60)
	if(ServiceLocator.safe_get_service(&"Player").canBeMilked()):
		amountCollected += ServiceLocator.safe_get_service(&"MainScene").SCI.processMilkPlayerBreasts()
		breastsMilked = true
		var thePump = GlobalRegistry.createItem("BreastPump")
		if(thePump):
			var theFluids = thePump.getFluids()
			if(theFluids):
				theFluids.addFluid("Milk", 400.0)
		ServiceLocator.safe_get_service(&"Player").getInventory().forceEquipStoreOtherUnlessRestraint(thePump)
	if(ServiceLocator.safe_get_service(&"Player").hasReachablePenis() || ServiceLocator.safe_get_service(&"Player").isWearingChastityCage()):
		amountCollected += ServiceLocator.safe_get_service(&"MainScene").SCI.processMilkPlayerPenis()
		penisMilked = true
	if(ServiceLocator.safe_get_service(&"Player").hasReachablePenis()):
		var thePump = GlobalRegistry.createItem("PenisPump")
		ServiceLocator.safe_get_service(&"Player").getInventory().forceEquipStoreOtherUnlessRestraint(thePump)
		hasPenisPump = true
	if(ServiceLocator.safe_get_service(&"Player").hasReachableVagina()):
		amountCollected += ServiceLocator.safe_get_service(&"MainScene").SCI.processMilkPlayerVagina()
		vaginaMilked = true
	ServiceLocator.safe_get_service(&"Player").orgasmFrom("eliza")

func _run():
	if(state == ""):
		addCharacter("eliza")
		aimCameraAndSetLocName("med_milkingroom")
		playAnimation(StageScene.Sybian, "intense", {pc="pc", chained=true, bodyState={naked=true, hard=true}})
		saynn("You ask Eliza to be fully milked.. and you get your wish granted.")

		saynn("Eliza sets you up on a sybian.."+str(" With a penis pump stroking your cock and a set of breasts pumps sucking away at your nips.." if (ServiceLocator.safe_get_service(&"Player").hasReachablePenis() && breastsMilked) else "")+""+str(" With a penis pump stroking your cock and a toy vibrating against your prostate.." if (ServiceLocator.safe_get_service(&"Player").hasReachablePenis() && !breastsMilked) else "")+""+str(" With a dildo vibrating against your prostate and a set of breast pumps sucking away at your nips.." if (ServiceLocator.safe_get_service(&"Player").isWearingChastityCage() && breastsMilked) else "")+""+str(" With a dildo vibrating against your prostate.." if (ServiceLocator.safe_get_service(&"Player").isWearingChastityCage() && !breastsMilked) else "")+""+str(" With a set of breast pumps sucking away at your nips.." if (!penisMilked && breastsMilked) else "")+"")

		saynn("It doesn't take long for you to cum.."+str(" Your pussy gushing from overstimulation, your girlcum collected into the funnel beneath the grated platform.." if vaginaMilked else "")+""+str(" Your {pc.cum} shooting out of your chastity cage, your prostate pulsing.." if ServiceLocator.safe_get_service(&"Player").isWearingChastityCage() else "")+""+str(" Your throbbing cock filling the penis pump with many spurts of your {pc.cum}.." if ServiceLocator.safe_get_service(&"Player").hasReachablePenis() else "")+""+str(" Your breasts squirting with {pc.milk}.." if breastsMilked else "")+"")

		saynn("After the process is done, Eliza brings you back into the lobby..")

		addButton("Continue", "See what happens next", "endthescene_removestuff")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return

	if(_action == "endthescene_removestuff"):
		if(hasPenisPump):
			ServiceLocator.safe_get_service(&"Player").getInventory().clearSlot(InventorySlot.Penis)
		if(breastsMilked):
			ServiceLocator.safe_get_service(&"Player").getInventory().clearSlot(InventorySlot.UnderwearTop)
		
		playAnimation(StageScene.Duo, "stand", {npc="eliza"})
		aimCameraAndSetLocName(ServiceLocator.safe_get_service(&"Player").getLocation())
		endScene()
		return

	setState(_action)

func saveData():
	var data = super.saveData()

	data["breastsMilked"] = breastsMilked
	data["penisMilked"] = penisMilked
	data["vaginaMilked"] = vaginaMilked
	data["hasPenisPump"] = hasPenisPump
	data["amountCollected"] = amountCollected

	return data

func loadData(data):
	super.loadData(data)

	breastsMilked = SAVE.loadVar(data, "breastsMilked", false)
	penisMilked = SAVE.loadVar(data, "penisMilked", false)
	vaginaMilked = SAVE.loadVar(data, "vaginaMilked", false)
	hasPenisPump = SAVE.loadVar(data, "hasPenisPump", false)
	amountCollected = SAVE.loadVar(data, "amountCollected", 0.0)
