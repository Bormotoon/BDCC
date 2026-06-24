extends Panel

func has_point(_point):
	var distance = pivot_offset.distance_to(_point)
	if(distance <= size.x / 2.0):
		return true
	return false
