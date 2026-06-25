extends CodeBlockBase

func getCategories():
	return ["Game"]

func getType():
	return CrotchBlocks.CALL

func execute(_contex:CodeContex):
	if(ServiceLocator.safe_get_service(&"MainScene") != null && is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return ServiceLocator.safe_get_service(&"MainScene").startNewDay()
	return 0

func getTemplate():
	return [
		{
			type = "label",
			text = "Start next day",
		},
	]
