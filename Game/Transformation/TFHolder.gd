extends RefCounted
class_name TFHolder

## MIGRATED to Godot 4 (GDScript 2.0).
## Transformation management with layered effects and replay.

var char_ref: WeakRef
var original_parts: Dictionary = {}
var effects: Array = []
var affected_parts: Dictionary = {}
var original_char_data: Dictionary = {}
var transformations: Array = []

const TFTYPE_CHAR: int = 0
const TFTYPE_PART: int = 1

func setCharacter(the_char) -> void:
	char_ref = weakref(the_char)

func getChar():
	if char_ref == null:
		return null
	return char_ref.get_ref()

## Tag-based exclusion check
func canStartTransformation(tf_id: String) -> bool:
	var new_tf = GlobalRegistry.getTransformationRef(tf_id)
	if new_tf == null or not new_tf.isPossibleFor(getChar()):
		return false
	if not getChar().isDynamicCharacter() and not getChar().isPlayer():
		return false
	if getChar().isPlayer():
		var encounter_settings = ServiceLocator.safe_get_service(&"MainScene").getEncounterSettings()
		if encounter_settings.getTFWeight(tf_id) <= 0.0:
			return false
	# Stack check
	if new_tf.canTFStack():
		for tf in transformations:
			if tf.id == tf_id:
				return true
	# Tag conflict check
	var current_tags: Dictionary = getCurrentTFTags()
	var new_tf_tags: Dictionary = new_tf.getTFCheckTags()
	for tag in new_tf_tags:
		if current_tags.has(tag):
			return false
	return true

func startTransformation(tf_id: String, args: Dictionary = {}):
	if not canStartTransformation(tf_id):
		return null
	var new_tf = GlobalRegistry.createTransformation(tf_id)
	if new_tf == null:
		return null
	transformations.append(new_tf)
	new_tf.uniqueID = GlobalRegistry.generateTFID()
	new_tf.setHolder(self)
	new_tf.startFinal(args)
	return new_tf

func hasActiveTransformations() -> bool:
	return not transformations.is_empty()

func hasTF(tf_id: String) -> bool:
	for tf in transformations:
		if tf.id == tf_id:
			return true
	return false

func getCurrentTFTags() -> Dictionary:
	var tags: Dictionary = {}
	for tf in transformations:
		for tag in tf.getTFTags():
			tags[tag] = true
	return tags

func undoTransformation(tf_id: String) -> void:
	for i in range(transformations.size() - 1, -1, -1):
		if transformations[i].id == tf_id:
			transformations[i].undoEffects()
			transformations.remove_at(i)
			break
	applyEffects()

func applyEffects() -> void:
	# Replay all effects from original data
	pass

func makeAllTransformationsPermanent() -> void:
	original_parts.clear()
	original_char_data.clear()
