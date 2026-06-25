extends RefCounted
class_name CodeContex

signal onPrint(text)
signal onError(codeBlock, text)
signal onGenericError(text)

var curLine:int = -1
var errored = false
var returning = false

var vars = {}
var varsDefinition = {}
var flags = {}
var flagsDefinition = {}

func hasVar(theVar:String):
	if(!vars.has(theVar)):
		return false
	return true

func getVar(theVar:String, defaultValue = null):
	if(!vars.has(theVar)):
		if(varsDefinition.has(theVar)):
			return varsDefinition[theVar]["default"]
		return defaultValue
	return vars[theVar]

func setVar(theVar:String, newValue, _codeblock):
	if(varsDefinition.has(theVar)):
		var varType = varsDefinition[theVar]["type"]
		
		if(varType == DatapackSceneVarType.BOOL && !(newValue is bool)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a BOOLEAN variable "+str(theVar))
			return
		if(varType == DatapackSceneVarType.STRING && !(newValue is String)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a STRING variable "+str(theVar))
			return
		if(varType == DatapackSceneVarType.NUMBER && !(newValue is int) && !(newValue is float)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a NUMBER variable "+str(theVar))
			return
	vars[theVar] = newValue

func clearVars():
	vars = {}

func hasFlag(theVar:String, _codeblock = null):
	if(!flagsDefinition.has(theVar)):
		return false
	return true

func getFlag(theVar:String, defaultValue = null, _codeblock = null):
	if(!flags.has(theVar)):
		if(flagsDefinition.has(theVar)):
			return flagsDefinition[theVar]["default"]
		return defaultValue
	return flags[theVar]

func setFlag(theVar:String, newValue, _codeblock):
	if(flagsDefinition.has(theVar)):
		var varType = flagsDefinition[theVar]["type"]
		
		if(varType == DatapackSceneVarType.BOOL && !(newValue is bool)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a BOOLEAN flag "+str(theVar))
			return
		if(varType == DatapackSceneVarType.STRING && !(newValue is String)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a STRING flag "+str(theVar))
			return
		if(varType == DatapackSceneVarType.NUMBER && !(newValue is int) && !(newValue is float)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a NUMBER flag "+str(theVar))
			return
	flags[theVar] = newValue

func getFlagRaw(theVar:String, defaultValue = null, _codeblock = null):
	if(ServiceLocator.safe_get_service(&"MainScene") == null):
		return getFlag(theVar, defaultValue, _codeblock)
	return ServiceLocator.safe_get_service(&"MainScene").getFlag(theVar, defaultValue)

func setFlagRaw(theVar:String, newValue, _codeblock = null):
	if(ServiceLocator.safe_get_service(&"MainScene") == null):
		return setFlag(theVar, newValue, _codeblock)
	return ServiceLocator.safe_get_service(&"MainScene").setFlag(theVar, newValue)

func hasFlagRaw(theVar:String, _codeblock = null):
	if(ServiceLocator.safe_get_service(&"MainScene") == null):
		return hasFlag(theVar, _codeblock)
	return ServiceLocator.safe_get_service(&"MainScene").hasFlag(theVar)

func doPrint(text):
	onPrint.emit(text)
	Log.msg(str(text))

func doDebugPrint(text):
	doPrint(text)

func hadAnError() -> bool:
	return errored

func resetErrored():
	errored = false

func shouldReturn() -> bool:
	return returning

func shouldBreak() -> bool:
	return false

func shouldContinue() -> bool:
	return false

func throwError(_codeblock, _errorText):
	errored = true
	
	if(_codeblock == null):
		onGenericError.emit(str(_errorText))
		Log.err("[CrotchScript Error] "+str(_errorText))
		return
	onError.emit(_codeblock, str(_errorText))
	Log.err("[CrotchScript Error at line "+str(_codeblock.lineNum)+"] "+str(_errorText))

func execute(slotCalls):
	#clearVars()
	returning = false
	errored = false
	calcLineNums(slotCalls)
	slotCalls.execute(self)

func getValue(slotVar):
	var result = slotVar.getValue(self)
	
	return result

func calcLineNums(slotCalls):
	curLine = 0
	slotCalls.calcLineNums(self)

func say(text):
	if(text.length() > 80):
		text = text.substr(0, 78)+"..."
	doPrint(text)

func sayn(text):
	say(text)

func saynn(text):
	say(text)

func sayAsCharacter(charID:String, sayText:String):
	saynn("[say="+charID+"]"+sayText+"[/say]")

func addMessage(text):
	doPrint("Adding message: "+str(text))

func addButton(_nameText, _descText, _state, _codeSlot, _buttonChecks):
	doPrint("BUTTON ADDED: "+str(_nameText))

func addDisabledButton(_nameText, _descText):
	doPrint("DISABLED BUTTON ADDED: "+str(_nameText))

func addCharacter(charAlias, _variant):
	if(charAlias == "pc"):
		throwError(null, "Trying to add the player character (pc) into the scene. There is no need to do that")
		return
	doPrint("ADDED CHAR: "+str(charAlias))

func removeCharacter(charAlias):
	doPrint("REMOVED CHAR: "+str(charAlias))

func aimCameraAndSetLocName(newLoc):
	doPrint("AIMING CAMERA AT "+str(newLoc))

func setLocName(newText):
	doPrint("Setting loc name to "+str(newText))

func playAnim(animID, _animData):
	doPrint("PLAYING ANIMATION: "+str(animID))

func doRunEvent():
	doPrint("EVENT WILL HAPPEN")
	setIsReturning()

func setIsReturning():
	returning = true

func markQuestAsVisible():
	pass

func markQuestAsCompleted():
	pass

func hasInterpolatorVar(varID):
	if(hasVar(varID) || hasFlag(varID)):
		return true
	return false

func getInterpolatorVar(varID):
	if(hasVar(varID)):
		return getVar(varID)
	if(hasFlag(varID)):
		return getFlag(varID)
	return null

func isNumber(val):
	if((val is float || val is int)):
		return true
	return false

func isString(val):
	if(val is String):
		return true
	return false

func getCharacterActualID(charID:String):
	return charID

func getCharacter(charID:String):
	var result = GlobalRegistry.getCharacter(getCharacterActualID(charID))
	if(result == null):
		throwError(null, "No character found: "+str(charID))
		return null
	return result

func isInGame():
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	return true

func addPain(charID:String, amValue:int):
	if(!isInGame()):
		return
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return
	theChar.addPain(amValue)

func addLust(charID:String, amValue:int):
	if(!isInGame()):
		return
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return
	theChar.addLust(amValue)

func addStamina(charID:String, amValue:int):
	if(!isInGame()):
		return
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return
	theChar.addStamina(amValue)

func getPain(charID:String) -> int:
	if(!isInGame()):
		return 0
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return 0
	return theChar.getPain()

func getLust(charID:String) -> int:
	if(!isInGame()):
		return 0
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return 0
	return theChar.getLust()

func getStamina(charID:String) -> int:
	if(!isInGame()):
		return 0
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return 0
	return theChar.getStamina()

func charMethod(charID:String, themethod:String, args:Array = [], defaultValue = null):
	if(!isInGame()):
		return defaultValue
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return defaultValue
	if(!theChar.has_method(themethod)):
		throwError(null, "No method found: "+str(themethod)+" for the character: "+str(charID))
		return defaultValue
	return theChar.callv(themethod, args)

func charInventoryMethod(charID:String, themethod:String, args:Array = [], defaultValue = null):
	if(!isInGame()):
		return defaultValue
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return defaultValue
	if(!theChar.getInventory().has_method(themethod)):
		throwError(null, "No method found: "+str(themethod)+" for the character's inventory: "+str(charID))
		return defaultValue
	return theChar.getInventory().callv(themethod, args)

func charPersonalityMethod(charID:String, themethod:String, args:Array = [], defaultValue = null):
	if(!isInGame()):
		return defaultValue
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return defaultValue
	if(!theChar.getPersonality().has_method(themethod)):
		throwError(null, "No method found: "+str(themethod)+" for the character's personality: "+str(charID))
		return defaultValue
	return theChar.getPersonality().callv(themethod, args)

func charFetishHolderMethod(charID:String, themethod:String, args:Array = [], defaultValue = null):
	if(!isInGame()):
		return defaultValue
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return defaultValue
	if(!theChar.getFetishHolder().has_method(themethod)):
		throwError(null, "No method found: "+str(themethod)+" for the character's personality: "+str(charID))
		return defaultValue
	return theChar.getFetishHolder().callv(themethod, args)

func getStat(charID:String, statName) -> int:
	if(!isInGame()):
		return 0
	
	var theChar = getCharacter(charID)
	if(theChar == null):
		return 0
	return theChar.getStat(statName)

func setState(newState:String):
	doPrint("Setting state to "+str(newState))

func getState():
	return ""

func endScene():
	doPrint("Ending the scene..")

func runScene(sceneID:String, _args = [], _codeSlot = null):
	doPrint("Gonna run scene: "+sceneID)

func runFightScene(charID:String, _codeWin, _codeLose):
	doPrint("Gonna start a fight with: "+charID)

func runGenericSexScene(domID:String, subID:String, _sexType:String, _codeSlot = null):
	doPrint("Gonna start a sex between "+domID+" and "+subID)

func runLeashParadeScene(domID:String, finalLoc:String, _codeSlot = null):
	doPrint("Gonna start a leashing scene with dom "+domID+" and target location being "+finalLoc)

func addStraponButtonsFor(_charName, _nextState, _codeSlot):
	pass

func returnStraponToPcFrom(_charName):
	return true

func addFilledCondomToLootIfPerk(_charName):
	return

func isInRunMode():
	return true

func isInReactMode():
	return true

func giveBirth(charName):
	var theChar = getCharacter(charName)
	if(theChar == null):
		return false
	
	var bornChilds = theChar.giveBirth()
	var bornChildAmount = bornChilds.size()
	var bornString = ServiceLocator.safe_get_service(&"ChildSystem").getChildBirthInfoString(bornChilds)
	
	if(bornChildAmount > 0 && ServiceLocator.safe_get_service(&"MainScene") != null && is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		ServiceLocator.safe_get_service(&"MainScene").addLogMessage("New life", ""+theChar.getName()+" gave birth to "+str(bornChildAmount)+" kid"+("s" if bornChildAmount != 1 else "")+":\n\n"+bornString)
		ServiceLocator.safe_get_service(&"MainScene").showLog()
		
		return true
	return false

func addLog(_logName, _logText):
	if(ServiceLocator.safe_get_service(&"MainScene") != null && is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		ServiceLocator.safe_get_service(&"MainScene").addLogMessage(_logName, _logText)
	else:
		doPrint("Adding log with title: "+str(_logName))

func showLog():
	if(ServiceLocator.safe_get_service(&"MainScene") != null && is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		ServiceLocator.safe_get_service(&"MainScene").showLog()

func characterExists(charID:String):
	return GlobalRegistry.characterExists(getCharacterActualID(charID))

func getChildAmount(charID:String):
	if(ServiceLocator.safe_get_service(&"ChildSystem") != null && is_instance_valid(ServiceLocator.safe_get_service(&"ChildSystem"))):
		return ServiceLocator.safe_get_service(&"ChildSystem").getChildrenAmountOf(getCharacterActualID(charID))
	
	return 0
func getChildAmountOnlyMother(charID:String):
	if(ServiceLocator.safe_get_service(&"ChildSystem") != null && is_instance_valid(ServiceLocator.safe_get_service(&"ChildSystem"))):
		return ServiceLocator.safe_get_service(&"ChildSystem").getChildrenAmountOfOnlyMother(getCharacterActualID(charID))
	
	return 0
func getChildAmountOnlyFather(charID:String):
	if(ServiceLocator.safe_get_service(&"ChildSystem") != null && is_instance_valid(ServiceLocator.safe_get_service(&"ChildSystem"))):
		return ServiceLocator.safe_get_service(&"ChildSystem").getChildrenAmountOfOnlyFather(getCharacterActualID(charID))
	
	return 0
func getChildAmountFatherMother(charID:String, charID2:String):
	if(ServiceLocator.safe_get_service(&"ChildSystem") != null && is_instance_valid(ServiceLocator.safe_get_service(&"ChildSystem"))):
		return ServiceLocator.safe_get_service(&"ChildSystem").getSharedChildrenAmountFatherMother(getCharacterActualID(charID), getCharacterActualID(charID2))
	
	return 0

func addImageByID(_imageID:String):
	pass

func shouldExecuteCodeOnce() -> bool:
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return true
	return ServiceLocator.safe_get_service(&"MainScene").shouldExecuteOnceCodeblocksRun()

func setBreastSize(charID:String, breastSize):
	var character:BaseCharacter = getCharacter(charID)
	
	if(character == null):
		return false
	if(!character.hasBodypart(BodypartSlot.Breasts)):
		return false
	var breasts = character.getBodypart(BodypartSlot.Breasts)
	breasts.setBreastSizeSafe(breastSize)
	character.updateAppearance()

func setPenisAndBallsSize(charID:String, penisLen:float, ballsSize:float = 1.0):
	var character = getCharacter(charID)
	
	if(character == null):
		return false
	if(!character.hasBodypart(BodypartSlot.Penis)):
		return false
	var penis = character.getBodypart(BodypartSlot.Penis)
	penis.lengthCM = penisLen
	penis.ballsScale = ballsSize
	character.updateAppearance()

func getBreastSize(charID:String):
	var character:BaseCharacter = getCharacter(charID)
	
	if(character == null):
		return 0
	if(!character.hasBodypart(BodypartSlot.Breasts)):
		return 0
	return character.getBodypart(BodypartSlot.Breasts).getSize()

func getOriginalBreastSize(charID:String):
	var character:BaseCharacter = getCharacter(charID)
	
	if(character == null):
		return 0
	if(!character.hasBodypart(BodypartSlot.Breasts)):
		return 0
	return character.getBodypart(BodypartSlot.Breasts).size

func getPenisLen(charID:String):
	var character:BaseCharacter = getCharacter(charID)
	
	if(character == null):
		return 0
	if(!character.hasBodypart(BodypartSlot.Penis)):
		return 0
	return character.getBodypart(BodypartSlot.Penis).getLength()

func getPenisBallsScale(charID:String):
	var character:BaseCharacter = getCharacter(charID)
	
	if(character == null):
		return 0
	if(!character.hasBodypart(BodypartSlot.Penis)):
		return 0
	return character.getBodypart(BodypartSlot.Penis).getBallsScale()

func setExcludeNpcFromEncounters(charID:String, newVal:bool):
	var character:BaseCharacter = getCharacter(charID)
	
	if(character == null):
		throwError(null, "No character found with id "+str(charID))
		return
	
	if(!(character.isDynamicCharacter())):
		throwError(null, "Character with id "+str(charID)+" is not a dynamic character. Unable to exclude (or include) them from encounters")
		return
	
	if(character.extraSettings == null):
		character.extraSettings = DynCharExtraSettings.new()
	
	character.extraSettings.excludeEncounters = newVal
	
func isDatapackLoaded(_datapackID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null):
		return true
	
	return ServiceLocator.safe_get_service(&"MainScene").loadedDatapacks.has(_datapackID)

func addPCRep(_repID:String, howMuch:float):
	if(ServiceLocator.safe_get_service(&"Player") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"Player"))):
		return
	
	var reputation:ReputationPlaceholder = ServiceLocator.safe_get_service(&"Player").getReputation()
	reputation.addRep(_repID, howMuch)
	
func setPCRepLevel(_repID:String, newLevel:int):
	if(ServiceLocator.safe_get_service(&"Player") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"Player"))):
		return
	
	var reputation:ReputationPlaceholder = ServiceLocator.safe_get_service(&"Player").getReputation()
	reputation.setLevel(_repID, newLevel)
	
func getPCRepLevel(_repID:String):
	if(ServiceLocator.safe_get_service(&"Player") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"Player"))):
		return
	
	var reputation:ReputationPlaceholder = ServiceLocator.safe_get_service(&"Player").getReputation()
	return reputation.getRepLevel(_repID)
	
func getPCRepScore(_repID:String):
	if(ServiceLocator.safe_get_service(&"Player") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"Player"))):
		return
	
	var reputation:ReputationPlaceholder = ServiceLocator.safe_get_service(&"Player").getReputation()
	return reputation.getRepScore(_repID)
	
func addAffection(char1ID:String, char2ID:String, howMuch:float):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return
	
	ServiceLocator.safe_get_service(&"MainScene").RS.addAffection(getCharacterActualID(char1ID), getCharacterActualID(char2ID), howMuch)
	
func setAffection(char1ID:String, char2ID:String, howMuch:float):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return
	
	ServiceLocator.safe_get_service(&"MainScene").RS.setAffection(getCharacterActualID(char1ID), getCharacterActualID(char2ID), howMuch)

func getAffection(char1ID:String, char2ID:String) -> float:
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return 0.0
	
	return ServiceLocator.safe_get_service(&"MainScene").RS.getAffection(getCharacterActualID(char1ID), getCharacterActualID(char2ID))

func addRelationshipLust(char1ID:String, char2ID:String, howMuch:float):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return
	
	ServiceLocator.safe_get_service(&"MainScene").RS.addLust(getCharacterActualID(char1ID), getCharacterActualID(char2ID), howMuch)
	
func setRelationshipLust(char1ID:String, char2ID:String, howMuch:float):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return
	
	ServiceLocator.safe_get_service(&"MainScene").RS.setLust(getCharacterActualID(char1ID), getCharacterActualID(char2ID), howMuch)

func getRelationshipLust(char1ID:String, char2ID:String) -> float:
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return 0.0
	
	return ServiceLocator.safe_get_service(&"MainScene").RS.getLust(getCharacterActualID(char1ID), getCharacterActualID(char2ID))



func canStartTF(charID:String, tfID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	return tfHolder.canStartTransformation(tfID)

func hasTF(charID:String, tfID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	return tfHolder.hasTF(tfID)

func hasTFFinalStage(charID:String, tfID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	return tfHolder.hasTFFinalStage(tfID)

func startTF(charID:String, tfID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	return tfHolder.startTransformation(tfID) != null

func startSpeciesTF(charID:String, speciesID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	return tfHolder.startTransformation("SpeciesTF", {species=[speciesID]}) != null

func startHybridSpeciesTF(charID:String, speciesID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	return tfHolder.startTransformation("SpeciesTFMinor", {species=[speciesID]}) != null

func forceProgressTFs(charID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	tfHolder.forceProgressAll()
	return true
	
func accelerateProgressTFs(charID:String, howMuch:float):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	tfHolder.accelerateAllFull(howMuch)
	return true

func makeTFsPermanent(charID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	tfHolder.makeAllTransformationsPermanent()
	return true
	
func undoAllTFs(charID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	var character:BaseCharacter = getCharacter(charID)
	if(character == null):
		return false
	var tfHolder:TFHolder = character.getTFHolder()
	if(!tfHolder):
		return false
	tfHolder.undoAllTransformations()
	return true

func isTFEffectUnlocked(tfID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	return ServiceLocator.safe_get_service(&"MainScene").SCI.isTransformationUnlocked(tfID)

func isTFEffectTested(tfID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	return ServiceLocator.safe_get_service(&"MainScene").SCI.isTransformationTested(tfID)

func hasAccessToTFLab():
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	return ServiceLocator.safe_get_service(&"MainScene").SCI.hasAccessToLab()

func doUnlockTF(tfID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	ServiceLocator.safe_get_service(&"MainScene").SCI.doUnlockTF(tfID)

func doTestTF(tfID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	ServiceLocator.safe_get_service(&"MainScene").SCI.doTestTF(tfID)

func addTFLabFluid(fluidID:String, amount:float):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return false
	ServiceLocator.safe_get_service(&"MainScene").SCI.addFluid(fluidID, amount)

func getTFLabFluid(fluidID:String):
	if(ServiceLocator.safe_get_service(&"MainScene") == null || !is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return 0.0
	return ServiceLocator.safe_get_service(&"MainScene").SCI.getFluidAmount(fluidID)
