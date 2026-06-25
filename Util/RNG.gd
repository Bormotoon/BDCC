extends Object
class_name RNG

## MIGRATED to Godot 4 (GDScript 2.0).
## Random number generation utilities.

static func randi_range(from: int, to: int) -> int:
	if from > to:
		Log.err("randi_range() from > to")
		to = from
	var rand_value := randi() % (to - from + 1) + from
	return rand_value

static func randf_range_custom(from: float, to: float) -> float:
	return randf() * (to - from) + from

static func randf_rangeX2(from: float, to: float) -> float:
	return (randf() * (to - from) + from + randf() * (to - from) + from) / 2.0

## chance(100) = always true, chance(3) = 3% of the time
static func chance(ch: float) -> bool:
	return randf() * 100.0 < ch

## Picks random element from array or random key from dictionary
static func pick(ar) -> Variant:
	if ar is Dictionary:
		ar = ar.keys()
	if ar.is_empty():
		return null
	return ar[randi() % ar.size()]

## Picks and removes random element
static func grab(ar) -> Variant:
	if ar is Dictionary:
		ar = ar.keys()
	if ar.is_empty():
		return null
	var element_i: int = randi() % ar.size()
	var value = ar[element_i]
	ar.remove_at(element_i)
	return value

## Weighted random selection
static func pickWeighted(ar, weights: Array) -> Variant:
	if ar is Dictionary:
		ar = ar.keys()
	if ar.is_empty():
		return null
	if ar.size() != weights.size():
		Log.err("RNG.pickWeighted: arrays differ in size")
		return null
	var total := 0.0
	for w in weights:
		total += w
	if total <= 0.0:
		return ar[randi() % ar.size()]
	var rand_val := randf() * total
	var cumulative := 0.0
	for i in range(ar.size()):
		cumulative += weights[i]
		if rand_val < cumulative:
			return ar[i]
	return ar[ar.size() - 1]

## Weighted random from pairs [item, weight]
static func pickWeightedPairs(pairs: Array) -> Variant:
	if pairs.is_empty():
		return null
	var total := 0.0
	for pair in pairs:
		total += pair[1]
	if total <= 0.0:
		return pairs[0]
	var rand_val := randf() * total
	var cumulative := 0.0
	for pair in pairs:
		cumulative += pair[1]
		if rand_val < cumulative:
			return pair
	return pairs[pairs.size() - 1]

## Pick n unique elements
static func pickN(ar, n: int) -> Array:
	if ar is Dictionary:
		ar = ar.keys()
	var copy: Array = ar.duplicate()
	var result: Array = []
	for _i in mini(n, copy.size()):
		var idx: int = randi() % copy.size()
		result.append(copy[idx])
		copy.remove_at(idx)
	return result

## Deterministic pick using a hash (same hash = same result)
static func pickHashed(ar, thehash: int) -> Variant:
	if ar is Dictionary:
		ar = ar.keys()
	if ar.is_empty():
		return null
	thehash = thehash % ar.size()
	return ar[thehash]

## Random male name from RNGData
static func randomMaleName() -> String:
	return pick(RNGData.maleNames)

## Random female name from RNGData
static func randomFemaleName() -> String:
	return pick(RNGData.femaleNames)

## Shuffle array in place
static func shuffle(ar: Array) -> void:
	for i in range(ar.size() - 1, 0, -1):
		var j := randi() % (i + 1)
		var temp = ar[i]
		ar[i] = ar[j]
		ar[j] = temp
