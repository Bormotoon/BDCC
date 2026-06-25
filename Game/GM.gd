extends Node

## GM singleton — thin compatibility layer over ServiceLocator.
## GM.* properties delegate to ServiceLocator internally.
## New code should use ServiceLocator.get_service() directly.

var ui:
	get:
		return ServiceLocator._services.get(&"UI", null)
	set(value):
		ServiceLocator.register_service(&"UI", value)

var main:
	get:
		return ServiceLocator._services.get(&"MainScene", null)
	set(value):
		ServiceLocator.register_service(&"MainScene", value)

var pc:
	get:
		return ServiceLocator._services.get(&"Player", null)
	set(value):
		ServiceLocator.register_service(&"Player", value)

var world:
	get:
		return ServiceLocator._services.get(&"World", null)
	set(value):
		ServiceLocator.register_service(&"World", value)

var ES:
	get:
		return ServiceLocator._services.get(&"EventSystem", null)
	set(value):
		ServiceLocator.register_service(&"EventSystem", value)

var QS:
	get:
		return ServiceLocator._services.get(&"QuestSystem", null)
	set(value):
		ServiceLocator.register_service(&"QuestSystem", value)

var CS:
	get:
		return ServiceLocator._services.get(&"ChildSystem", null)
	set(value):
		ServiceLocator.register_service(&"ChildSystem", value)

var GES:
	get:
		return ServiceLocator._services.get(&"GameExtenderSystem", null)
	set(value):
		ServiceLocator.register_service(&"GameExtenderSystem", value)

var PROFILE:
	get:
		return ServiceLocator._services.get(&"Profiler", null)
	set(value):
		ServiceLocator.register_service(&"Profiler", value)

func _init():
	GES = GameExtenderSystem.new()
	PROFILE = _create_profiler()

func _ready():
	var directory = DirAccess.open(".")
	directory.make_dir("user://saves")
	directory.make_dir("user://mods")
	directory.make_dir("user://custom_skins")
	directory.make_dir("user://datapacks")

func _create_profiler():
	if OPTIONS.should_profile():
		return MyProfiler.new()
	else:
		return MyProfilerBase.new()

func register_services() -> void:
	if main:
		ServiceLocator.register_service(&"MainScene", main)
	if pc:
		ServiceLocator.register_service(&"Player", pc)
	if world:
		ServiceLocator.register_service(&"World", world)
	if ui:
		ServiceLocator.register_service(&"UI", ui)
	if ES:
		ServiceLocator.register_service(&"EventSystem", ES)
	if QS:
		ServiceLocator.register_service(&"QuestSystem", QS)
	if CS:
		ServiceLocator.register_service(&"ChildSystem", CS)
	if GES:
		ServiceLocator.register_service(&"GameExtenderSystem", GES)
	if PROFILE:
		ServiceLocator.register_service(&"Profiler", PROFILE)
