extends RefCounted
class_name EventBase

## MIGRATED to Godot 4 (GDScript 2.0).
## Base class for events. extends Reference → RefCounted.

var id: String = "badevent"

func registerTriggers(_es) -> void:
	pass

func react(_trigger_id, _args) -> void:
	pass

func run(_trigger_id, _args) -> void:
	pass

func getPriority() -> int:
	return 10

func onButton(_method, _args) -> void:
	pass

func eventCheck(_check_id, _args: Array = []):
	return null

func doEventCheck(_check_id, _args: Array = []):
	if GM.ES:
		return GM.ES.eventCheck(_check_id, _args)

func checkCharacterBusy(_check_id, message_if_busy: String, character_name: String = "") -> bool:
	var check_data = doEventCheck(_check_id)
	if check_data == null:
		return false
	if check_data is Dictionary and check_data.has("text"):
		saynn(check_data["text"])
	else:
		saynn(message_if_busy)
	if character_name != "":
		addDisabledButton(character_name, "They are not here")
	return true

func runScene(scene_id: String, args: Array = [], tag: String = "") -> void:
	GM.main.runScene(scene_id, args)

func say(_text: String) -> void:
	if GM.ui:
		GM.ui.say(_text)

func sayn(_text: String) -> void:
	say(_text + "\n")

func saynn(_text: String) -> void:
	say(_text + "\n\n")

func addButton(text: String, tooltip: String = "", method: String = "", args: Array = []) -> void:
	GM.ui.addButton(text, tooltip, "EVENTSYSTEM_BUTTON", [self, method, args])

func addDisabledButton(text: String, tooltip: String = "") -> void:
	GM.ui.addDisabledButton(text, tooltip)

func addButtonUnlessLate(text: String, tooltip: String = "", method: String = "", args: Array = [], latetext: String = "It's way too late for that") -> void:
	if GM.main.isVeryLate():
		addDisabledButton(text, latetext)
	else:
		addButton(text, tooltip, method, args)

func addButtonWithChecks(text: String, tooltip: String, method: String, args, checks: Array) -> void:
	var bad_check = ButtonChecks.check(checks)
	if bad_check == null:
		addButton(text, ButtonChecks.getPrefix(checks) + tooltip, method, args)
	else:
		addDisabledButton(text, ButtonChecks.getReasonText(bad_check))

func setFlag(flag_id, value) -> void:
	GM.main.setFlag(flag_id, value)

func getFlag(flag_id, default_value = null):
	return GM.main.getFlag(flag_id, default_value)

func increaseFlag(flag_id, add_value = 1) -> void:
	GM.main.increaseFlag(flag_id, add_value)
