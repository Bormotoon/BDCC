extends CodeBlockBase

var varSlot := CrotchSlotVar.new()

func getCategories():
	return ["Game"]

func _init():
	varSlot.setRawType(CrotchVarType.NUMBER)
	varSlot.setRawValue(12*60*60)

func getType():
	return CrotchBlocks.CALL

func execute(_contex:CodeContex):
	var amValue = varSlot.getValue(_contex)
	if(_contex.hadAnError()):
		return

	if(!isNumber(amValue)):
		throwError(_contex, "Argument must be a number, got "+str(amValue)+" instead")
		return
	
	if(ServiceLocator.safe_get_service(&"MainScene") != null && is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		ServiceLocator.safe_get_service(&"MainScene").processTimeUntil(amValue)

func getTemplate():
	return [
		{
			type = "label",
			text = "Process time UNTIL",
		},
		{
			type = "slot",
			id = "var",
			slot = varSlot,
			slotType = CrotchBlocks.VALUE,
			minsize = 110,
		},
		{
			type = "label",
			text = "s",
		},
	]

func getSlot(_id):
	if(_id == "var"):
		return varSlot

