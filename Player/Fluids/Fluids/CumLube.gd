extends FluidBase

func _init():
	id = "CumLube"

func getVisibleName():
	return "Cum Lube"

func getCumOverlayColor():
	return Color.LIGHT_GRAY

func canStoreInFluidTank() -> bool:
	return false
