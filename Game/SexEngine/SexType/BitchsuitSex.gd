extends SexTypeBase

func _init():
	id = SexType.BitchsuitSex

func getDefaultAnimation():
	var sexEngine = getSexEngine()
	var theDomIDs:Array = sexEngine.getXFreeDomIDsForAnim(1)
	var theSubIDs:Array = sexEngine.getXFreeSubIDsForAnim(1)
	
	if(theSubIDs.is_empty() && theDomIDs.is_empty()):
		return null
	
	if(theSubIDs.is_empty()):
		return [StageScene.Solo, "stand", {pc=theDomIDs[0]}]
	if(theDomIDs.is_empty()):
		return [StageScene.PuppySolo, "stand" if !isUnconscious(theSubIDs[0]) else "sad", {pc=theSubIDs[0]}]
	
	if(isUnconscious(theSubIDs[0])):
		return [StageScene.PuppySexStart, "sad", {pc=theDomIDs[0], npc=theSubIDs[0]}]
	return [StageScene.PuppySexStart, "start", {pc=theDomIDs[0], npc=theSubIDs[0]}]
