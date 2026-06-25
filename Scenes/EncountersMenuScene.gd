extends SceneBase

var pickedPoolToShow = ""
var pickedFetishToChange = ""
var pickedPersonalityStat = ""
var pickedGenderToChange = ""
var pickedSpeciesToChange = ""
var pickedGoalIDToChange = ""
var pickedTFIDToChange = ""
var npclistScene = preload("res://UI/NpcList/NpcList.tscn") 

func _init():
	sceneID = "EncountersMenuScene"

func _run():
	if(state == ""):
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		
		saynn("This is a menu that contains info about characters that you have met or might meet.")
		
		var hasSomeoneToForget = false
		sayn("You remember that prison has:")
		var encounterPools = ServiceLocator.safe_get_service(&"MainScene").getDynamicCharactersPools()
		if(encounterPools.size() == 0):
			sayn(" - Nothing, explore to find more characters")
		for encounterPoolID in encounterPools:
			var amount = ServiceLocator.safe_get_service(&"MainScene").getDynamicCharactersPoolSize(encounterPoolID)
			
			sayn(CharacterPool.getVisibleName(encounterPoolID)+": "+str(amount))
			hasSomeoneToForget = true
		sayn("")
		
		if(encounterSettings.doesPreferKnownEncounters()):
			saynn("Known characters: You prefer to encounter characters that you already saw.")
		else:
			saynn("Known characters: You don't mind meeting new characters.")
		
		if(ServiceLocator.safe_get_service(&"Player").dynamicPersonality):
			saynn("Dynamic personality: Your personality or fetishes can dynamically change after sex.")
		else:
			saynn("Dynamic personality: Your personality or fetishes will never change after sex.")
		
		if(encounterSettings.shouldSubThreesomesBeEnabled()):
			saynn("Threesomes: You don't mind being a sub in threesomes.")
		else:
			saynn("Threesomes: Doms will never dynamically join the sex if you are a sub.")
		
		sayn("Relative chances for the genders of encountered npcs:")
		for gender in NpcGender.getAll():
			var genderName = NpcGender.getVisibleNameColored(gender)
			var extraInfo = ""
			var genderExlanation = NpcGender.getGenderExplanation(gender)
			if(genderExlanation != null && genderExlanation != ""):
				extraInfo = " ("+str(genderExlanation)+")"
			
			var weight = encounterSettings.getGenderWeight(gender)
			sayn(str(genderName)+": "+str(Util.roundF(weight*100.0, 1))+"%"+extraInfo)
		sayn("")
		
		sayn("Relative chances for the species of encountered npcs:")
		var species = GlobalRegistry.getAllPlayableSpecies()
		for speciesID in species:
			var speciesObject:Species = species[speciesID]
			var speciesName = speciesObject.getVisibleName()
			
			var weight = encounterSettings.getSpeciesWeight(speciesID)
			sayn(str(speciesName)+": "+str(Util.roundF(weight*100.0, 1))+"%")
		sayn("")
		
		sayn("Things that npcs won't do to you:")
		var disabledGoalsNames = []
		var allGoals = GlobalRegistry.getSexGoals()
		for goalID in allGoals:
			if(encounterSettings.isGoalDisabledForSubPC(goalID)):
				var goal: SexGoalBase = GlobalRegistry.getSexGoal(goalID)
				if(goal == null):
					continue
				
				disabledGoalsNames.append(goal.getVisibleName())
		if(disabledGoalsNames.size() == 0):
			saynn("- Nothing is disabled")
		else:
			saynn(Util.humanReadableList(disabledGoalsNames))
		
		addButton("Back", "Close this menu", "endthescene")
		
		if(hasSomeoneToForget):
			addButton("Characters", "Shows any randomly generated characters that you encountered", "npclistmenu")
		else:
			addDisabledButton("Characters", "You haven't met any randomly generated characters")
		
		addButton("Toggle known", "Toggle between meeting only old characters and meeting both old and new", "toggleKnown")
		addButton("Dynamic personality", "Change the way your personality changes after sex", "togglePersonalityChange")
		addButton("Threesomes (sub)", "Toggle the ability for extra doms to join the sex when you are a sub", "toggleThreesomesSub")
		addButton("My fetishes", "Menu that allows you to see and change your fetishes", "fetishmenu")
		addButton("My personality", "Menu that allows you to see and change your personality", "personalitymenu")
		addButton("Genders", "Pick the chances of the genders of the encountered npcs", "gendersmenu")
		addButton("Species", "Pick the chances of the species of the encountered npcs", "speciesmenu")
		addButton("Restrictions", "Pick what things you don't want to happen to you in sex", "goalsmenu")
		addButton("Goal weights", "Change the weights of sex goals that other characters will persue during sex", "goalweightsmenu")
		addButton("TFs weights", "Change the weights of transformations that 'strange pills' might contain", "tfweightsmenu")

	if(state == "goalweightsmenu"):
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		addButton("Back", "Close this menu", "")
		
		sayn("These are the current weights of all sex goals:")
		var allGoals = GlobalRegistry.getSexGoals()
		for goalID in allGoals:
			var goal: SexGoalBase = GlobalRegistry.getSexGoal(goalID)
			if(goal == null):
				continue
			var goalWeight = encounterSettings.getGoalWeight(goalID, goal.getGoalDefaultWeight())
			
			sayn(goal.getVisibleName()+": "+str(Util.roundF(goalWeight*100.0, 1))+"%")
			addButton(goal.getVisibleName(), "Change the weight of this goal", "changegoalweightmenu", [goalID])
		
	if(state == "tfweightsmenu"):
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		addButton("Back", "Close this menu", "")
		
		sayn("These are the current weights of all transformations that might be caused by 'strange pills':")
		var allTFs = GlobalRegistry.getTransformationRefs()
		for tfID in allTFs:
			var tf: TFBase = GlobalRegistry.getTransformationRef(tfID)
			if(tf == null || !tf.canChangeWeight()):
				continue
			var tfWeight = encounterSettings.getTFWeight(tfID, tf.getPillGenWeight())
			
			var pillName:String = tf.getPillName()
			var tfName:String = tf.getName()
			
			if(pillName != tfName):
				sayn(pillName+" ("+tfName+"): "+str(Util.roundF(tfWeight*100.0, 1))+"%")
			else:
				sayn(tfName+": "+str(Util.roundF(tfWeight*100.0, 1))+"%")
			addButton(tf.getName(), "Change the weight of this transformation", "changetfweightmenu", [tfID])
		
	if(state == "changegoalweightmenu"):
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		addButton("Back", "Close this menu", "")
		var pickedGoal = GlobalRegistry.getSexGoal(pickedGoalIDToChange)
		if(pickedGoal != null):
			var goalWeight = encounterSettings.getGoalWeight(pickedGoalIDToChange, pickedGoal.getGoalDefaultWeight())
			saynn("The current weight for '"+pickedGoal.getVisibleName()+"' goal is "+str(Util.roundF(goalWeight*100.0, 1))+"%")
			
			addButton("Default", "Reset the weight to the default value", "changegoalweight", [-1])
			
			var possibleWeights = [0.0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.7, 0.9, 1.0, 1.2, 1.5, 2.0, 3.0, 5.0]
			for weight in possibleWeights:
				var weightStr = str(Util.roundF(weight*100.0, 1))+"%"
				
				addButton(weightStr, "Set the weight to this value", "changegoalweight", [weight])
			
	if(state == "changetfweightmenu"):
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		addButton("Back", "Close this menu", "")
		var pickedTF:TFBase = GlobalRegistry.getTransformationRef(pickedTFIDToChange)
		if(pickedTF != null):
			var goalWeight = encounterSettings.getTFWeight(pickedTFIDToChange, pickedTF.getPillGenWeight())
			saynn("The current weight for '"+pickedTF.getName()+"' transformation is "+str(Util.roundF(goalWeight*100.0, 1))+"%")
			
			addButton("Default", "Reset the weight to the default value", "changetfweight", [-1])
			
			var possibleWeights = [0.0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.7, 0.9, 1.0, 1.2, 1.5, 2.0, 3.0, 5.0]
			for weight in possibleWeights:
				var weightStr = str(Util.roundF(weight*100.0, 1))+"%"
				
				addButton(weightStr, "Set the weight to this value", "changetfweight", [weight])
			
		
	if(state == "goalsmenu"):
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		addButton("Back", "Close this menu", "")
		
		sayn("Things that npcs won't do to you:")
		var disabledGoalsNames = []
		var allGoals = GlobalRegistry.getSexGoals()
		for goalID in allGoals:
			var goal: SexGoalBase = GlobalRegistry.getSexGoal(goalID)
			if(goal == null):
				continue
			
			if(encounterSettings.isGoalDisabledForSubPC(goalID)):
				disabledGoalsNames.append(goal.getVisibleName())
				addButton("+"+goal.getVisibleName(), "Enable this", "enablegoalforpc", [goalID])
			else:
				addButton("-"+goal.getVisibleName(), "Disable this", "disablegoalforpc", [goalID])
		if(disabledGoalsNames.size() == 0):
			saynn("- Nothing is disabled")
		else:
			saynn(Util.humanReadableList(disabledGoalsNames))

	if(state == "speciesmenu"):
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		addButton("Back", "Close this menu", "")
		
		sayn("Relative chances for the species of encountered npcs:")
		var species = GlobalRegistry.getAllPlayableSpecies()
		for speciesID in species:
			var speciesObject:Species = species[speciesID]
			var speciesName = speciesObject.getVisibleName()
			
			var weight = encounterSettings.getSpeciesWeight(speciesID)
			sayn(str(speciesName)+": "+str(Util.roundF(weight*100.0, 1))+"%")
			addButton(speciesName, "Change the chance of this species", "specieschancemenu", [speciesID])
		sayn("")

	if(state == "gendersmenu"):
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		addButton("Back", "Close this menu", "")
		
		sayn("Relative chances for the genders of encountered npcs:")
		for gender in NpcGender.getAll():
			var genderName = NpcGender.getVisibleNameColored(gender)
			var extraInfo = ""
			var genderExlanation = NpcGender.getGenderExplanation(gender)
			if(genderExlanation != null && genderExlanation != ""):
				extraInfo = " ("+str(genderExlanation)+")"
			
			var weight = encounterSettings.getGenderWeight(gender)
			sayn(str(genderName)+": "+str(Util.roundF(weight*100.0, 1))+"%"+extraInfo)
			addButton(NpcGender.getVisibleName(gender), "Change the chance of this gender", "genderchancemenu", [gender])
		sayn("")

	if(state == "genderchancemenu"):
		var gender = pickedGenderToChange
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		saynn("The current chance for "+NpcGender.getVisibleNameColored(gender)+" is "+str(Util.roundF(encounterSettings.getGenderWeight(gender)*100.0, 1))+"%")

		addButton("Back", "Go back to the previous menu", "gendersmenu")
		addButton("Default", "Set back to default chance", "setgenderchance", [gender, -1.0])
		for chance in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
			addButton(str(Util.roundF(chance*100.0))+"%", "Pick this chance", "setgenderchance", [gender, chance])

	if(state == "specieschancemenu"):
		var species = pickedSpeciesToChange
		var encounterSettings:EncounterSettings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		var speciesObject:Species = GlobalRegistry.getSpecies(species)
		if(!speciesObject):
			speciesObject = GlobalRegistry.getSpecies(Species.Canine)
		var speciesName = speciesObject.getVisibleName()
		saynn("The current chance for "+speciesName+" is "+str(Util.roundF(encounterSettings.getSpeciesWeight(species)*100.0, 1))+"%")

		addButton("Back", "Go back to the previous menu", "speciesmenu")
		addButton("Default", "Set back to default chance", "setspecieschance", [species, -1.0])
		for chance in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.5, 2.0, 3.0]:
			addButton(str(Util.roundF(chance*100.0))+"%", "Pick this chance", "setspecieschance", [species, chance])

	if(state == "npclistmenu"):
		var encounterPools = ServiceLocator.safe_get_service(&"MainScene").getDynamicCharactersPools()

		saynn("Select which occupation the character that you want to look for has.")
		saynn("You can forget any character in the list so they will never show up again. This action can not be undone.")
		saynn("Keep in mind that if this character is pregnant, their pregnancy will be forgotten too. But any kids you had together will stay.")

		addButton("Back", "Go back a level", "") 
		
		for encounterPoolID in encounterPools:
			addButton(CharacterPool.getVisibleName(encounterPoolID), "Pick this occupation", "occupationmenupool", [encounterPoolID])
		
	if(state == "occupationmenupool"):
		var npclist = npclistScene.instantiate()
		ServiceLocator.safe_get_service(&"UI").addFullScreenCustomControl("npclist", npclist)
		var _ok = npclist.onMeetNpcButton.connect(doMeetNpc)
		
		var characterIDS = ServiceLocator.safe_get_service(&"MainScene").getDynamicCharacterIDsFromPool(pickedPoolToShow)
		for characterID in characterIDS:
			var dynamicCharacter: BaseCharacter  = GlobalRegistry.getCharacter(characterID)
			if(dynamicCharacter == null):
				continue
			var NPCname = dynamicCharacter.getName()
			if(dynamicCharacter.hasEnslaveQuest()):
				NPCname = "(!) "+NPCname
			var gender = NpcGender.getVisibleName(dynamicCharacter.npcGeneratedGender)
			var subbyStat = dynamicCharacter.getPersonality().getStat(PersonalityStat.Subby)
			var sharedKidsAmount = ServiceLocator.safe_get_service(&"ChildSystem").getSharedChildrenAmount("pc", characterID)

			npclist.addRow(NPCname, gender, subbyStat, characterID, pickedPoolToShow, sharedKidsAmount, dynamicCharacter.canForgetCharacter(), dynamicCharacter.canMeetCharacter())
	
		addButton("Back", "Go back a level", "closenpclist")
		
		var encounterPools = ServiceLocator.safe_get_service(&"MainScene").getDynamicCharactersPools()
		for encounterPoolID in encounterPools:
			addButton(CharacterPool.getVisibleName(encounterPoolID), "Pick this occupation", "occupationmenupool", [encounterPoolID])

	if(state == "fetishmenu"):
		var fetishHolder = ServiceLocator.safe_get_service(&"Player").getFetishHolder()
		saynn("Having a fetish for something means you will get more lust doing this activity during sex.")
		addButton("Go back", "Go back a menu", "")
		
		sayn("Your fetishes:")
		for fetishID in GlobalRegistry.getFetishes():
			var fetish = GlobalRegistry.getFetish(fetishID)
			var fetishValue:float = fetishHolder.getFetish(fetishID)
			var fetishColor = FetishInterest.getColorString(fetishValue)
			var fetishInterestText = FetishInterest.getVisibleName(fetishValue)
			
			sayn(fetish.getVisibleName()+": "+"[color="+fetishColor+"]"+fetishInterestText+"[/color]")
			
			addButton(fetish.getVisibleName(), "Change how much you enjoy this fetish", "changefetish", [fetishID])
		
	if(state == "changefetish"):
		var fetishHolder = ServiceLocator.safe_get_service(&"Player").getFetishHolder()
		var fetish = GlobalRegistry.getFetish(pickedFetishToChange)
		if(fetish != null):
			saynn("Your current value for '"+fetish.getVisibleName()+"' fetish is "+FetishInterest.getVisibleName(fetishHolder.getFetish(pickedFetishToChange)))
			
			saynn("Pick your new value for this fetish")
			
			for fetishInterest in FetishInterest.getAll():
				addButton(FetishInterest.getVisibleName(fetishInterest), "Change to this", "changeinterest", [fetishInterest])
			
			
		addButton("Back", "Don't change anything", "fetishmenu")
		
	if(state == "personalitymenu"):
		var personality: Personality = ServiceLocator.safe_get_service(&"Player").getPersonality()
		saynn("Your personality has a minor effect on how you react during sex.")
		addButton("Go back", "Go back a menu", "")
		
		sayn("Your personality:")
		for statID in PersonalityStat.getAll():
			var value = personality.getStat(statID)
			var statName = PersonalityStat.getVisibleName(statID)
			var statValue = PersonalityStat.getVisibleDesc(statID, value)
			
			sayn(statName+": "+statValue+" (Raw value is "+str(Util.roundF(value*100.0,1))+"%)")
			addButton(statName, "Change this personality stat", "changepersonality", [statID])
	
	if(state == "changepersonality"):
		var personality: Personality = ServiceLocator.safe_get_service(&"Player").getPersonality()
		var value = personality.getStat(pickedPersonalityStat)
		var statName = PersonalityStat.getVisibleName(pickedPersonalityStat)
		var statValue = PersonalityStat.getVisibleDesc(pickedPersonalityStat, value)
		
		saynn("Your current raw value for '"+statName+"' personality stat is "+str(Util.roundF(value*100.0,1))+"% (or '"+str(statValue)+"')")
		
		addButton("Done", "Enough changing", "personalitymenu")
		addButton("-15%", "Change the personality stat", "changepersonalitystatby", [-0.15])
		addButton("-5%", "Change the personality stat", "changepersonalitystatby", [-0.05])
		addButton("-1%", "Change the personality stat", "changepersonalitystatby", [-0.01])
		addButton("+1%", "Change the personality stat", "changepersonalitystatby", [0.01])
		addButton("+5%", "Change the personality stat", "changepersonalitystatby", [0.05])
		addButton("+15%", "Change the personality stat", "changepersonalitystatby", [0.15])
		
func doMeetNpc(ID, occupation):
	var pcLoc:String = ServiceLocator.safe_get_service(&"Player").getLocation()
	if(ServiceLocator.safe_get_service(&"MainScene").IS.hasPawn(ID)):
		ServiceLocator.safe_get_service(&"UI").getCustomControl("npclist").sendPopupMessage("This person is already somewhere in the prison\nYou can find them by exploring around")
		return
	
	if(!ServiceLocator.safe_get_service(&"World").isLocSafe(pcLoc)):
		ServiceLocator.safe_get_service(&"UI").getCustomControl("npclist").sendPopupMessage("This location isn't safe, you can't meet anyone here!")
		return
	if(!ServiceLocator.safe_get_service(&"World").canMeetInLoc(pcLoc)):
		ServiceLocator.safe_get_service(&"UI").getCustomControl("npclist").sendPopupMessage("You can't meet anyone on this floor!")
		return
	
	if(occupation in ["Inmates", "Guards", "Engineers", "Nurses"]):
		if(ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.MeetDynamicNPC, [ID]) || ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.TalkingToDynamicNPC, [ID])):
			endScene([true])
			ServiceLocator.safe_get_service(&"MainScene").runCurrentScene()
			return
		if(getCharacter(ID).shouldBeExcludedFromEncounters()):
			ServiceLocator.safe_get_service(&"UI").getCustomControl("npclist").sendPopupMessage("It feels like you will never find them..")
			return
		var pawn:CharacterPawn = ServiceLocator.safe_get_service(&"MainScene").IS.spawnPawn(ID)
		if(pawn == null):
			return
		pawn.setLocation(ServiceLocator.safe_get_service(&"Player").getLocation())
		ServiceLocator.safe_get_service(&"MainScene").IS.startInteraction("Talking", {starter="pc", reacter=ID})
		endScene([true])
		ServiceLocator.safe_get_service(&"MainScene").runCurrentScene()
		return
	else:
		if(ServiceLocator.safe_get_service(&"EventSystem").triggerReact(Trigger.MeetDynamicNPC, [ID])):
			endScene([true])
			ServiceLocator.safe_get_service(&"MainScene").runCurrentScene()
			return

		
func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
		
	if(_action == "enablegoalforpc"):
		ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().enableGoalForSubPC(_args[0])
		return
	
	if(_action == "disablegoalforpc"):
		ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().disableGoalForSubPC(_args[0])
		return
	
	if(_action == "changefetish"):
		pickedFetishToChange = _args[0]
	
	if(_action == "changepersonality"):
		pickedPersonalityStat = _args[0]
	
	if(_action == "changepersonalitystatby"):
		var personality: Personality = ServiceLocator.safe_get_service(&"Player").getPersonality()
		personality.addStat(pickedPersonalityStat, _args[0])
		return
	
	if(_action == "changeinterest"):
		var fetishHolder = ServiceLocator.safe_get_service(&"Player").getFetishHolder()
		var fetish = GlobalRegistry.getFetish(pickedFetishToChange)
		if(fetish != null):
			fetishHolder.setFetish(pickedFetishToChange, _args[0])
		setState("fetishmenu")
		return
	
	if(_action == "toggleKnown"):
		ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().togglePreferKnownEcnounters()
		return
	
	if(_action == "togglePersonalityChange"):
		ServiceLocator.safe_get_service(&"Player").dynamicPersonality = !ServiceLocator.safe_get_service(&"Player").dynamicPersonality
		return 
		
	if(_action == "toggleThreesomesSub"):
		ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().toggleThreesomesSub()
		return 
	
	if(_action == "occupationmenupool"):
		pickedPoolToShow = _args[0]
	
	if(_action == "genderchancemenu"):
		pickedGenderToChange = _args[0]
	
	if(_action == "specieschancemenu"):
		pickedSpeciesToChange = _args[0]
		
	if(_action == "changegoalweightmenu"):
		pickedGoalIDToChange = _args[0]
		
	if(_action == "changetfweightmenu"):
		pickedTFIDToChange = _args[0]
	
	if(_action == "setgenderchance"):
		ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().setGenderWeight(_args[0], _args[1])
		
		setState("gendersmenu")
		return	
		
	if(_action == "setspecieschance"):
		ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().setSpeciesWeight(_args[0], _args[1])
		
		setState("speciesmenu")
		return
		
	if(_action == "changegoalweight"):
		if(_args[0] < 0):
			ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().resetGoalWeight(pickedGoalIDToChange)
		else:
			ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().setGoalWeight(pickedGoalIDToChange, _args[0])
		setState("goalweightsmenu")
		return
		
		
	if(_action == "changetfweight"):
		if(_args[0] < 0):
			ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().resetTFWeight(pickedTFIDToChange)
		else:
			ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings().setTFWeight(pickedTFIDToChange, _args[0])
		setState("tfweightsmenu")
		return
		
	if(_action == "closenpclist"):
		setState("")
		ServiceLocator.safe_get_service(&"UI").clearCharactersPanel()
		ServiceLocator.safe_get_service(&"MainScene").playAnimation(StageScene.Solo, "stand")
		return
		
	setState(_action)

func saveData():
	var data = super.saveData()
	
	data["pickedPoolToShow"] = pickedPoolToShow
	data["pickedFetishToChange"] = pickedFetishToChange
	data["pickedPersonalityStat"] = pickedPersonalityStat
	data["pickedGenderToChange"] = pickedGenderToChange
	data["pickedSpeciesToChange"] = pickedSpeciesToChange
	data["pickedGoalIDToChange"] = pickedGoalIDToChange
	data["pickedTFIDToChange"] = pickedTFIDToChange

	return data
	
func loadData(data):
	super.loadData(data)
	
	pickedPoolToShow = SAVE.loadVar(data, "pickedPoolToShow", "")
	pickedFetishToChange = SAVE.loadVar(data, "pickedFetishToChange", "")
	pickedPersonalityStat = SAVE.loadVar(data, "pickedPersonalityStat", "")
	pickedGenderToChange = SAVE.loadVar(data, "pickedGenderToChange", "")
	pickedSpeciesToChange = SAVE.loadVar(data, "pickedSpeciesToChange", "")
	pickedGoalIDToChange = SAVE.loadVar(data, "pickedGoalIDToChange", "")
	pickedTFIDToChange = SAVE.loadVar(data, "pickedTFIDToChange", "")
