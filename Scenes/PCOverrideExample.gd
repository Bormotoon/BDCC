extends SceneBase

func _init():
	sceneID = "PCOverrideExample"

func _reactInit():
	if(!ServiceLocator.safe_get_service(&"Player").isOverriddenPlayer()):
		ServiceLocator.safe_get_service(&"MainScene").overridePC()
		ServiceLocator.safe_get_service(&"Player").setName("Tavi")
		ServiceLocator.safe_get_service(&"Player").setGender(Gender.Female)
		ServiceLocator.safe_get_service(&"Player").setSpecies([Species.Feline])
		ServiceLocator.safe_get_service(&"Player").resetBodypartsToDefault()
		ServiceLocator.safe_get_service(&"Player").giveBodypart(GlobalRegistry.createBodypart("tavihair"))
		
		ServiceLocator.safe_get_service(&"Player").updateAppearance()
		ServiceLocator.safe_get_service(&"Player").updateNonBattleEffects()
		playAnimationForceReset(StageScene.Solo, "stand")

func _onSceneEnd():
	pass
	#ServiceLocator.safe_get_service(&"MainScene").clearOverridePC()
	#ServiceLocator.safe_get_service(&"Player").updateAppearance()
	#ServiceLocator.safe_get_service(&"Player").updateNonBattleEffects()

func _run():
	if(state == ""):
		saynn("Hello. Your name is {pc.name}")
		
		saynn("[say=pc]Yes, my name is {pc.name}[/say]")

		addButton("Quit", "Stop the scene", "endthescene")
		addButton("Clear override", "Nya", "clear_override")

func _react(_action: String, _args):

	if(_action == "endthescene"):
		endScene()
		return
	
	if(_action == "clear_override"):
		ServiceLocator.safe_get_service(&"MainScene").clearOverridePC()
		ServiceLocator.safe_get_service(&"Player").updateAppearance()
		ServiceLocator.safe_get_service(&"Player").updateNonBattleEffects()
		playAnimationForceReset(StageScene.Solo, "stand")
		endScene()
		return

	
	setState(_action)
