extends SceneEndScene

func getCategories():
	return ["Event"]

func getTemplate():
	return [
		{
			type = "label",
			text = "End Current Scene",
		},
	]
