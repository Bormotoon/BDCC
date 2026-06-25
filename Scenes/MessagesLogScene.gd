extends SceneBase

func _init():
	sceneID = "MessagesLogScene"

func _run():
	if(state == ""):
		saynn("Things that happened:")
		
		for messageData in ServiceLocator.safe_get_service(&"MainScene").getLogMessages():
			var title = messageData["title"]
			var message = messageData["message"]
			
			sayn("[b]"+title+"[/b]")
			saynn(message)
		
		addButton("Close", "Close the log", "endthescene")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		ServiceLocator.safe_get_service(&"MainScene").clearLog()
		endScene()
		return

func _react_scene_end(_tag, _result):
	setState("")
