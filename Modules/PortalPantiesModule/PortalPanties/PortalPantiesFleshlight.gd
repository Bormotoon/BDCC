extends ItemBase

func _init():
	id = "PortalPantiesFleshlight"

func getVisibleName():
	return "Fleshlight"
	
func getDescription():
	return "A sci-fi looking fleshlight that has buttons on it."

func getPossibleActions():
	return [
		{
			"name": "Activate",
			"scene": "UsePortalPantiesFleshlight",
			"description": "See what the fleshlight can do",
			"onlyWhenCalm": true,
		},
	]

func getPrice():
	return 10

func canSell():
	return true

func getTags():
	if(ServiceLocator.safe_get_service(&"MainScene") != null && (ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_PcDenied") || ServiceLocator.safe_get_service(&"MainScene").getFlag("PortalPantiesModule.Panties_FleshlightsReturnedToAlex"))):
		return [ItemTag.SoldByAlexRynard]
	return []

func getItemCategory():
	return ItemCategory.BDSM

func getInventoryImage():
	return "res://Images/Items/bdsm/PortalPantiesFleshlight.png"
