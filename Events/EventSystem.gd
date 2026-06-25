extends Node
class_name EventSystem

## MIGRATED to Godot 4 (GDScript 2.0).
## Event registration and dispatch system.

var event_triggers: Dictionary = {}
var event_checks: Dictionary = {}
var datapack_events: Array = []

func _ready() -> void:
	ServiceLocator.register_service(&"EventSystem", self)
	name = "EventSystem"
	_registerEventTriggers()
	_registerEvents()

func _registerEventTriggers() -> void:
	registerEventTrigger(Trigger.EnteringRoom, EventTriggerLocation.new())
	registerEventTrigger(Trigger.EnteringRoomWithSlave, EventTriggerLocation.new())
	registerEventTrigger(Trigger.TalkingToNPC, EventTriggerLocation.new())
	registerEventTrigger(Trigger.CaughtStealingInGreenhouse, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.CaughtOffLimits, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.HighExposureInmateEvent, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.PCLookingForTrouble, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.MasturbationSpottedGuard, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.MasturbationSpottedInmate, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.AboutToSleepInCell, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.SleepInCell, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.SceneAndStateHook, EventTriggerSceneHook.new())
	registerEventTrigger(Trigger.SlaverySlutLookAtEvent, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.SlaverySlutImportantEvent, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.TalkingToDynamicNPC, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.MeetDynamicNPC, EventTriggerWeighted.new())
	registerEventTrigger(Trigger.UnconsciousPCGrabbed, EventTriggerWeighted.new())
	var modules = GlobalRegistry.getModules()
	for module_id in modules:
		modules[module_id].registerEventTriggers()

func _registerEvents() -> void:
	var loaded_events = GlobalRegistry.getEvents()
	for event_id in loaded_events:
		loaded_events[event_id].registerTriggers(self)
	for trigger_id in event_triggers:
		event_triggers[trigger_id].onAllEventsAdded()

func registerEventTrigger(trigger_id, event_trigger_object) -> void:
	event_trigger_object.id = trigger_id
	event_triggers[trigger_id] = event_trigger_object

func addTrigger(event, trigger_id, args: Array = []) -> void:
	if not event_triggers.has(trigger_id):
		registerEventTrigger(trigger_id, EventTriggerPriority.new())
	event_triggers[trigger_id].addEvent(event, args)

func triggerReact(trigger_id, args: Array = []) -> bool:
	if not event_triggers.has(trigger_id):
		return false
	return event_triggers[trigger_id].triggerReact(args)

func triggerRun(trigger_id, args: Array = []) -> void:
	if not event_triggers.has(trigger_id):
		return
	event_triggers[trigger_id].triggerRun(args)

func checkButtonInput(method: String, args: Array) -> bool:
	if method == "EVENTSYSTEM_BUTTON":
		args[0].onButton(args[1], args[2])
		return true
	return false

func addEventCheck(event, check_id: String) -> void:
	if not event_checks.has(check_id):
		event_checks[check_id] = []
	event_checks[check_id].append(event)

func eventCheck(check_id: String, args: Array = []):
	if not event_checks.has(check_id):
		return null
	for the_event_check in event_checks[check_id]:
		var check_data = the_event_check.eventCheck(check_id, args)
		if check_data != null:
			return check_data
	return null

func saveData() -> Dictionary:
	return {}

func loadData(_data: Dictionary) -> void:
	pass
