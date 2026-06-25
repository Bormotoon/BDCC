extends Control

var perk
signal perkClicked(perkID)
var showCost:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setPerk(theperk: PerkBase, shouldShowCost:bool = true):
	perk = theperk
	showCost = shouldShowCost

	if(ServiceLocator.safe_get_service(&"Player").getSkillsHolder().hasPerk(perk.id)):
		modulate = Color.GREEN
	elif(ServiceLocator.safe_get_service(&"Player").getSkillsHolder().isPerkDisabled(perk.id)):
		modulate = Color.YELLOW
	elif(!ServiceLocator.safe_get_service(&"Player").getSkillsHolder().canUnlockPerk(perk.id)):
		modulate = Color.RED
	else:
		modulate = Color.WHITE
	
	$PerkButtonRect.texture = load(perk.getPicture())


func _on_TextureButton_pressed():
	perkClicked.emit(perk.id if perk != null else "")


func _on_TextureButton_mouse_entered():
	if(perk == null):
		return
	GlobalTooltip.showTooltip(self, perk.getVisibleName(), (("Cost: "+str(perk.getCost())+"\n") if showCost else "")+perk.getVisibleDescription())


func _on_TextureButton_mouse_exited():
	GlobalTooltip.hideTooltip(self)

func setSkippedPerk():
	$PerkButtonRect.texture = preload("res://UI/SkillsUI/sprites/perkSkip.png")
