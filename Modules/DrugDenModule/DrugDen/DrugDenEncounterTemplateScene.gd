extends SceneBase
class_name DrugDenEncounterTemplateScene

var npcID:String = ""
var wonState:String = ""
var expWin:int = 50

func _init():
	sceneID = "DrugDenEncounterTemplateScene"

func generateJunkieNPCID(_isBoss:bool = false) -> String:
	var theGenerator := DrugDenJunkieGenerator.new()
	var theChar:BaseCharacter = theGenerator.generate({
		NpcGen.Temporary: true,
		NpcGen.IsBoss: _isBoss,
	})
	var theID:String = theChar.id
	
	return theID

func resolveCustomCharacterName(_charID):
	if(_charID == "npc"):
		return npcID

func startFightWithNPC(theBattleName:String = "DrugDenEncounter"):
	runScene("FightScene", [npcID, theBattleName], "encounterFight")

func _react_scene_end(_tag, _result):
	if(_tag == "encounterFight"):
		processTime(10 * 60)
		var battlestate = _result[0]
		
		if(ServiceLocator.safe_get_service(&"MainScene").DrugDenRun != null):
			ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.markEncounterAsCompleted(ServiceLocator.safe_get_service(&"Player").getLocation())
		
		if(battlestate == "win"):
			#setState("won_encounter")
			if(wonState == ""):
				playAnimation(StageScene.Solo, "stand")
				endScene()
			else:
				setState(wonState)
			addExperienceToPlayer(expWin)
			
			if(ServiceLocator.safe_get_service(&"MainScene").DrugDenRun.shouldShowLevelUpScreen()):
				runScene("DungeonLevelUpScene")
		else:
			setState("lost_encounter")

	if(_tag == "defeated_sex"):
		var sexResult:SexEngineResult = _result[0]
		var gotUncon:bool = sexResult.isSubUnconscious("pc")
		
		if(gotUncon):
			setState("encounter_fully_rekt")
		else:
			setState("encounter_survived_sex")
		return

func encounter_run():
	if(state == "lost_encounter"):
		playAnimation(StageScene.Duo, "defeat", {npc=npcID})
		
		saynn("You lost! Looks like the junkie is eager to fuck you.")
		
		addButton("Continue", "See what happens next", "start_defeated_sex")
	
	if(state == "encounter_survived_sex"):
		removeCharacter(npcID)
		saynn("You managed to endure the onslaught! Time to run!")
		
		addButton("Continue", "See what happens next", "endthescene")
		
	if(state == "encounter_fully_rekt"):
		removeCharacter(npcID)
		playAnimation(StageScene.Sleeping, "sleep")
		
		saynn("You got chocked out completely..")
		
		saynn("All you see is darkness..")
		
		addButton("Continue", "See what happens next", "encounter_endrun")
	
	if(state == "encounter_medical"):
		clearCharacter()
		playAnimation(StageScene.Sleeping, "sleep")
		addCharacter("eliza")
		aimCameraAndSetLocName("medical_hospitalwards")
	
		saynn("[say=eliza]Wakey-wakey![/say]")
		
		saynn("You open your eyes.. and realize that you're somewhere in the medical wing.")
		
		saynn("[say=eliza]Nanobots worked like a charm! I treated some of your injuries while you were taking a nap. Eat this muffin too, you're starving![/say]")
	
		saynn("She gives you a muffin. You eat it immediately. It tastes like the best thing you have ever eaten in your life.")
	
		saynn("[say=pc]Thanks..[/say]")
		
		saynn("She points at a drawer near your hospital bed.")
		
		saynn("[say=eliza]All your things are in there.[/say]")
		
		saynn("You get up, grab all your belongings and prepare to follow Eliza.")
		
		addButton("Follow", "See where she will bring you", "encounter_back_to_lobby")
		
	if(state == "encounter_back_to_lobby"):
		ServiceLocator.safe_get_service(&"Player").setLocation("med_lobbymain")
		aimCameraAndSetLocName("med_lobbymain")
		playAnimation(StageScene.Duo, "stand", {npc="eliza"})
		
		saynn("Eliza brings you out into the lobby.")
		
		saynn("[say=eliza]Take care now![/say]")
		
		addButton("Continue", "Time to go!", "endthescene")
		addButton("Run back", "Rush back to the hidden drug den entrance", "encounter_endthescene_rushback")
	
func encounter_react(_action: String, _args):
	if(_action == "start_defeated_sex"):
		getCharacter(npcID).prepareForSexAsDom()
		runScene("GenericSexScene", [npcID, "pc", SexType.DefaultSex, {SexMod.SubMustGoUnconscious:true, SexMod.DisableDynamicJoiners:true}], "defeated_sex")
		return true
	if(_action == "encounter_endrun"):
		ServiceLocator.safe_get_service(&"MainScene").processTime(2*60*60)
		ServiceLocator.safe_get_service(&"Player").setLocation("medical_hospitalwards")
		ServiceLocator.safe_get_service(&"MainScene").stopDungeonRun()
		ServiceLocator.safe_get_service(&"Player").addPain(-ServiceLocator.safe_get_service(&"Player").getPain())
		ServiceLocator.safe_get_service(&"Player").addLust(-ServiceLocator.safe_get_service(&"Player").getLust())
		ServiceLocator.safe_get_service(&"Player").addStamina(ServiceLocator.safe_get_service(&"Player").getMaxStamina())
		setState("encounter_medical")
		return true
	if(_action == "encounter_back_to_lobby"):
		setState("encounter_back_to_lobby")
		return true
	if(_action == "encounter_endthescene_rushback"):
		ServiceLocator.safe_get_service(&"Player").setLocation("yard_deadend2")
		endScene()
		return true
	
	return false

func saveData():
	var data = super.saveData()
	
	data["npcID"] = npcID
	
	return data
	
func loadData(data):
	super.loadData(data)
	
	npcID = SAVE.loadVar(data, "npcID", "")
