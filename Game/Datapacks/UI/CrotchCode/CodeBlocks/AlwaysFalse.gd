extends CodeBlockBase

func getCategories():
	return ["Logic"]

func getType():
	return CrotchBlocks.LOGIC

func execute(_contex:CodeContex):
	return false

func getTemplate():
	return [
		{
			type = "label",
			text = "FALSE",
		},
	]
