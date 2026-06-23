extends SexTypeBase

func _init():
	id = SexType.StocksSex

func getDefaultAnimation():
	var sexEngine = getSexEngine()
	var theDomIDs:Array = sexEngine.getXFreeDomIDsForAnim(1)
	var theSubIDs:Array = sexEngine.getXFreeSubIDsForAnim(1)
	
	if(theSubIDs.is_empty() && theDomIDs.is_empty()):
		return null
	
	if(theSubIDs.is_empty()):
		return [StageScene.Solo, "stand", {pc=theDomIDs[0]}]
	if(theDomIDs.is_empty()):
		return [StageScene.Stocks, "idle", {pc=theSubIDs[0]}]
	
	return [StageScene.StocksSexOral, "tease", {npc=theDomIDs[0], pc=theSubIDs[0]}]
