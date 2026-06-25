extends BaseAction


func _init():
	id = "endcondition"

func getName():
	return "End Condition"

func getVisibleText():
	return "END_CONDITION"

func generateCode():
	return ""

func changesFlow():
	return -1
