extends HBoxContainer

var statID
signal onPlusButton(statID, amount)

func setStatName(statName: String):
	$Label.text = statName

func setCanPressPlus(can):
	if(can):
		$PlusButton.disabled = false
		$PlusFiveButton.disabled = false
		$PlusTenButton.disabled = false
	else:
		$PlusButton.disabled = true
		$PlusFiveButton.disabled = true
		$PlusTenButton.disabled = true


func _on_SkillStatLine_mouse_entered():
	var stat: StatBase = GlobalRegistry.getStat(statID)
	if(stat != null):
		GlobalTooltip.showTooltip(self, stat.getVisibleName(), stat.getVisibleDescription())


func _on_SkillStatLine_mouse_exited():
	GlobalTooltip.hideTooltip(self)


func _on_PlusButton_pressed():
	onPlusButton.emit(statID, 1)


func _on_PlusFiveButton_pressed():
	onPlusButton.emit(statID, 5)


func _on_PlusTenButton_pressed():
	onPlusButton.emit(statID, 10)
