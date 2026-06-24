extends Node

## Migrated GM singleton.
## Old properties kept for backward compatibility.
## New code should use ServiceLocator.get_service() instead.

var ui # GameUI
var main # MainScene
var pc # Player
var world # GameWorld
var ES # EventSystem
var QS # QuestSystem
var CS # ChildSystem
var GES # GameExtenderSystem
var PROFILE # MyProfilerBase

func _init():
	GES = GameExtenderSystem.new()
	createProfiler()

func _ready():
	var directory = DirAccess.open(".")
	directory.make_dir("user://saves")
	directory.make_dir("user://mods")
	directory.make_dir("user://custom_skins")
	directory.make_dir("user://datapacks")

func createProfiler():
	if OPTIONS.should_profile():
		PROFILE = MyProfiler.new()
	else:
		PROFILE = MyProfilerBase.new()

## Register all subsystems into ServiceLocator for new code.
## Call this after MainScene is fully initialized.
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
