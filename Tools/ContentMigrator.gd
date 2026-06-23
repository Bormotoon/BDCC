# Tools/ContentMigrator.gd
@tool
class_name ContentMigrator extends EditorScript

## Migrated from QuestSystem.gd (49 lines) and GlobalRegistry quest/character registration.
## Batch converts old GDScript quest/character definitions into new .tres resources.

func _run() -> void:
	print("[ContentMigrator] Starting batch migration...")
	_migrate_quests()
	_migrate_characters_summary()
	print("[ContentMigrator] Migration complete!")

## Migrates old quest scripts to QuestData resources
func _migrate_quests() -> void:
	var quest_folder := "res://Quests/Quest/"
	var dir := DirAccess.open(quest_folder)
	if not dir:
		push_error("[ContentMigrator] Cannot open quest folder: %s" % quest_folder)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	var count := 0

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".gd"):
			var quest_data := QuestData.new()
			quest_data.quest_id = StringName(file_name.get_basename())

			# Load old script to extract metadata
			var script_path := quest_folder.path_join(file_name)
			var loaded := load(script_path)
			if loaded:
				var instance = loaded.new()
				if instance.has_method("getVisibleName"):
					quest_data.title = str(instance.getVisibleName())
				if instance.has_method("getProgress"):
					var progress = instance.getProgress()
					if progress is Array:
						quest_data.stages = progress

			# Save as .tres
			var save_path := "res://Resources/Quests/%s.tres" % file_name.get_basename()
			var err := ResourceSaver.save(quest_data, save_path)
			if err == OK:
				print("  Migrated quest: %s -> %s" % [file_name, save_path])
				count += 1
			else:
				push_error("  Failed to save quest: %s (error %d)" % [save_path, err])

		file_name = dir.get_next()

	print("[ContentMigrator] Migrated %d quests" % count)

## Generates summary of old characters for reference
func _migrate_characters_summary() -> void:
	var summary_path := "res://Resources/migration_summary.txt"
	var summary := "BDCC Migration Summary\n"
	summary += "====================\n\n"

	# Count old quest scripts
	var quest_dir := DirAccess.open("res://Quests/Quest/")
	if quest_dir:
		quest_dir.list_dir_begin()
		var count := 0
		var fn := quest_dir.get_next()
		while fn != "":
			if not quest_dir.current_is_dir() and fn.ends_with(".gd"):
				count += 1
			fn = quest_dir.get_next()
		summary += "Old quest scripts found: %d\n" % count

	# Count new quest resources
	var new_dir := DirAccess.open("res://Resources/Quests/")
	if new_dir:
		new_dir.list_dir_begin()
		var count := 0
		var fn := new_dir.get_next()
		while fn != "":
			if not new_dir.current_is_dir() and fn.ends_with(".tres"):
				count += 1
			fn = new_dir.get_next()
		summary += "New quest resources created: %d\n" % count

	# Count modules
	var module_dir := DirAccess.open("res://Modules/")
	if module_dir:
		module_dir.list_dir_begin()
		var count := 0
		var fn := module_dir.get_next()
		while fn != "":
			if module_dir.current_is_dir():
				count += 1
			fn = module_dir.get_next()
		summary += "Modules found: %d\n" % count

	# Count registered classes
	summary += "Global script classes in project.godot: removed (Godot 4 auto-detects)\n"

	var file := FileAccess.open(summary_path, FileAccess.WRITE)
	if file:
		file.store_string(summary)
		file.close()
		print("[ContentMigrator] Summary written to: %s" % summary_path)
