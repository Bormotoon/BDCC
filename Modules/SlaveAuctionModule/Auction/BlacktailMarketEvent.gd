extends EventBase

func _init():
	id = "BlacktailMarketEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoom, "market_intro")
	es.addTrigger(self, Trigger.EnteringRoom, "market_market")
	#es.addTrigger(self, Trigger.EnteringPlayerCell) # Handled in a different scene
	
func run(_triggerID, _args):
	var noMirri = getModule("SlaveAuctionModule").noMirri()
	
	if(noMirri && ServiceLocator.safe_get_service(&"Player").getLocation() == "market_market"):
		addButton("Sell slave", "Start an auction!", "soloslavesell")
		if(getFlag("SlaveAuctionModule.upgradeSeePrefs", 0) >= 1):
			addButton("Bidders info", "Check the preferences of the next bidders", "solobidders")
		addButton("Upgrades", "Upgrade the Blacktail Market", "soloupgrades")
		
		addButton("Prison cell", "Teleport back to your prison cell", "exitsecure")
	
	if(ServiceLocator.safe_get_service(&"Player").getLocation() == "market_intro"):
		addButton("Prison cell", "Teleport back to your prison cell", "exitsecure")
		if(noMirri):
			addButton("Laptop", "Use Mirri's laptop to order stuff", "mirrilaptop")
	
		if(!noMirri):
			if(getFlag("SlaveAuctionModule.beganAuctionOnce") && !getFlag("SlaveAuctionModule.luxeIntroHap")):
				addDisabledButton("Mirri", "She is not here..")
				
				saynn("You hear loud chatter coming from the room at the end of the corridor..")
			else:
				if(!checkCharacterBusy("MirriBusy", "Seems like the catgirl is not here", "Mirri")):
					addButton("Mirri", "Talk with the catgirl", "mirri")
				
	if(true):
		if(ServiceLocator.safe_get_service(&"Player").getLocation() == ServiceLocator.safe_get_service(&"Player").getCellLocation()):
			addButton("Blacktail Market", "Teleport to the Blacktail Market", "entersecure")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "mirrilaptop"):
		runScene("MirriBuySellScene")
	if(_method == "entersecure"):
		var noMirri = getModule("SlaveAuctionModule").noMirri()
		if(noMirri):
			ServiceLocator.safe_get_service(&"Player").setLocation("market_market")
		else:
			ServiceLocator.safe_get_service(&"Player").setLocation("market_intro")
		addMessage("You use your bluespace relay-tag to teleport to the Blacktail Market.")
		ServiceLocator.safe_get_service(&"MainScene").reRun()
	if(_method == "mirri"):
		if(!ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.TalkingToNPC, ["mirri"])):
			getCharacter("mirri").updateBodyparts()
			runScene("MirriTalkScene")
	if(_method == "exitsecure"):
		ServiceLocator.safe_get_service(&"Player").setLocation(ServiceLocator.safe_get_service(&"Player").getCellLocation())
		addMessage("You use the teleporter to teleport back to your cell.")
		ServiceLocator.safe_get_service(&"MainScene").reRun()
	if(_method == "soloslavesell"):
		runScene("SlaveAuctionGenericSellNoMirriScene")
	if(_method == "solobidders"):
		runScene("SlaveAuctionBiddersScene")
	if(_method == "soloupgrades"):
		runScene("SlaveAuctionUpgradesScene")
