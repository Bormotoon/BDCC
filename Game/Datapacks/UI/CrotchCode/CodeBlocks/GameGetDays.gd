extends CodeBlockBase


func getCategories():
	return ["Game"]

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	if(ServiceLocator.safe_get_service(&"MainScene") != null && is_instance_valid(ServiceLocator.safe_get_service(&"MainScene"))):
		return ServiceLocator.safe_get_service(&"MainScene").getDays()
	return 0

func getTemplate():
	return [
		{
			type = "label",
			text = "Get days",
		},
	]

