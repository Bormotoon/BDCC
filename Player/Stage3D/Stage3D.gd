extends Node3D
class_name Stage3D

var currentScene
@onready var animPlayer = $AnimationPlayer

func _ready():
	resetToNothing() # Player is created late
	#call_deferred("play", StageScene.Duo, "kneel", {npc="nova"}) # Player is created late
	#play(StageScene.Solo, "stand")

func play(sceneID, actionID, args = {}, skipFade = false, forceReset = false):
	if(currentScene != null && currentScene.id == sceneID && !forceReset && currentScene.canTransitionTo(actionID, args)):
		currentScene.playAnimationFinal(actionID, args)
		return
	
	if(currentScene != null):
		if(!skipFade):
			animPlayer.play("Fade")
			await animPlayer.animation_finished
			animPlayer.play_backwards("Fade")
		currentScene.queue_free()
		currentScene = null
	
	var newScene = GlobalRegistry.createStageScene(sceneID)
	if(newScene == null):
		Log.err("STAGE: Scene "+str(sceneID)+" wasn't found")
		return
	currentScene = newScene
	add_child(newScene)
	newScene.playAnimationFinal(actionID, args)

func updateSubAnims():
	if(currentScene != null):
		currentScene.updateSubAnims()

func resetToNothing():
	play(StageScene.Nothing, "", [], true)
