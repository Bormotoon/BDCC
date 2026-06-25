extends CodeBlockBase

func getCategories():
	return ["Logic"]

func getType():
	return CrotchBlocks.VALUE

func execute(_contex:CodeContex):
	return null

func getTemplate():
	return [
		{
			type = "label",
			text = "NULL",
		},
	]
