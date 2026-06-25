extends Object
class_name SexEventHelper

static func create(theType:String, theSourceID:String, theTargetID:String, theData = {}):
	var newEvent = SexEvent.new()
	newEvent.type = theType
	newEvent.sourceCharID = theSourceID
	newEvent.targetCharID = theTargetID
	newEvent.data = theData
	
	# Hacky, yes
	# But it's the best I can do
	if(ServiceLocator.safe_get_service(&"MainScene") != null):
		for scene in ServiceLocator.safe_get_service(&"MainScene").sceneStack:
			if(scene.sceneID == "GenericSexScene"):
				newEvent.isSexEngine = true
				newEvent.sexEngine = scene.sexEngine
				break
	
	return newEvent
