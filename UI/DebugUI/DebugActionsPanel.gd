extends Control

var debugActionScene = preload("res://UI/DebugUI/DebugActionButton.tscn")
@onready var debugActionArgsWindow = $DebugActionArgumentsWindow

func updateActions():
	Util.delete_children($VBoxContainer/VBoxContainer)
	Util.delete_children($VBoxContainer/VBoxContainer2)
	
	if(ServiceLocator.safe_get_service(&"MainScene") == null):
		return
	var currentScene : SceneBase = ServiceLocator.safe_get_service(&"MainScene").getCurrentScene()
	if(currentScene == null):
		return
	
	#print(currentScene.sceneID)
	var actions = currentScene.getDebugActions()
	if(actions == null || !(actions is Array)):
		return
	
	for action in actions:
		var debugActionObject = debugActionScene.instantiate()
		
		var _ok = debugActionObject.onActionPressed.connect(onDebugAction)
		$VBoxContainer/VBoxContainer.add_child(debugActionObject)
		debugActionObject.id = action["id"]
		debugActionObject.setText(action["name"])
		debugActionObject.actionName = action["name"]
		if(action.has("args")):
			debugActionObject.args = action["args"]
		debugActionObject.isMain = false
		
	for action in ServiceLocator.safe_get_service(&"MainScene").getDebugActions():
		var debugActionObject = debugActionScene.instantiate()
		
		var _ok = debugActionObject.onActionPressed.connect(onDebugAction)
		$VBoxContainer/VBoxContainer2.add_child(debugActionObject)
		debugActionObject.id = action["id"]
		debugActionObject.setText(action["name"])
		debugActionObject.actionName = action["name"]
		if(action.has("args")):
			debugActionObject.args = action["args"]
		debugActionObject.isMain = true
		
func onDebugAction(debugAction):
	#print(debugAction.id)
	
	if(ServiceLocator.safe_get_service(&"MainScene") == null):
		return

	if(debugAction.args == null || debugAction.args.size() == 0):
		_on_DebugActionArgumentsWindow_onDoActionButton(debugAction.id, debugAction.isMain, {})
		#currentScene.doDebugAction(debugAction.id, debugAction.args)
		#ServiceLocator.safe_get_service(&"MainScene").reRun()
	else:
		debugActionArgsWindow.setData(debugAction.id, debugAction.args, debugAction.isMain, debugAction.actionName)
		debugActionArgsWindow.popup_centered()


func _on_DebugActionsPanel_visibility_changed():
	if(visible):
		updateActions()

func _on_DebugActionArgumentsWindow_onDoActionButton(actionID, isMain, result):
	#print(actionID, " ", result)
	if(isMain):
		if(ServiceLocator.safe_get_service(&"MainScene") == null):
			return
		ServiceLocator.safe_get_service(&"MainScene").doDebugAction(actionID, result)
		ServiceLocator.safe_get_service(&"MainScene").reRun()
	else:
		if(ServiceLocator.safe_get_service(&"MainScene") == null):
			return
		var currentScene : SceneBase = ServiceLocator.safe_get_service(&"MainScene").getCurrentScene()
		if(currentScene == null):
			return
		currentScene.doDebugAction(actionID, result)
		ServiceLocator.safe_get_service(&"MainScene").reRun()
