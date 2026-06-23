extends Node

## MIGRATED to Godot 4 (GDScript 2.0).
## Portable mode detector. DirAccess → DirAccess.

func _init() -> void:
	var exe_dir := OS.get_executable_path().get_base_dir()
	var portable_dir := exe_dir.path_join("BDCCData/")

	if DirAccess.dir_exists_absolute(portable_dir):
		call_deferred("delayedLogPrint", "Using portable save directory: " + portable_dir)

		var portable_dir_suffix := "/Godot/app_userdata/BDCC"
		if OS.get_name() == "Linux":
			portable_dir_suffix = "/.local/share/godot/app_userdata/BDCC"
		if not DirAccess.dir_exists_absolute(portable_dir.path_join(portable_dir_suffix)):
			DirAccess.make_dir_recursive_absolute(portable_dir.path_join(portable_dir_suffix))

		if OS.has_environment("APPDATA"):
			OS.set_environment("APPDATA", portable_dir)
		if OS.has_environment("HOME"):
			OS.set_environment("HOME", portable_dir)

func _ready() -> void:
	queue_free()

func delayedLogPrint(the_text: String) -> void:
	print(the_text)
