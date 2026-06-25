extends CodeBlockBase

func getCategories():
	return ["Game"]

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	if(ServiceLocator.safe_get_service(&"MainScene") != null && is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return Util.getTimeStringHHMM(ServiceLocator.safe_get_service(&"MainScene").getTime())
	return "06:00"

func getTemplate():
	return [
		{
			type = "label",
			text = "Get time formatted",
		},
	]
