#!/usr/bin/env -S godot --headless -s
extends SceneTree

var passed: int = 0
var failed: int = 0
var error_list: Array[String] = []

func _init():
	print("=== BDCC Headless Test Suite ===")
	test_project_settings()
	test_critical_scenes()
	test_critical_scripts()
	test_critical_resources()
	test_no_godot3_patterns()
	test_autoload_scripts()
	print_summary()
	quit(0 if failed == 0 else 1)

func report(test_name: String, ok: bool, msg: String = ""):
	if ok:
		passed += 1
		print("  [PASS] ", test_name)
	else:
		failed += 1
		error_list.append(test_name + ": " + msg)
		var suffix: String = (" - " + msg) if not msg.is_empty() else ""
		print("  [FAIL] ", test_name, suffix)

func test_project_settings():
	print("\n--- Project Settings ---")
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene", "")
	report("Main scene configured", not main_scene.is_empty())
	report("Main scene exists", ResourceLoader.exists(main_scene))
	# Autoload count test removed - in -s mode ProjectSettings doesn't expose autoloads

func test_critical_scenes():
	print("\n--- Critical Scenes ---")
	var scenes: Array[String] = [
		"res://UI/LaunchScreen/LaunchScreen.tscn",
		"res://UI/LoadingScreen.tscn",
		"res://Game/UI/GameUI.tscn",
		"res://UI/MainMenu/MainMenu.tscn",
	]
	for scene_path in scenes:
		var name: String = scene_path.get_file()
		if ResourceLoader.exists(scene_path):
			var scene: PackedScene = load(scene_path) as PackedScene
			report("Scene loads: " + name, scene != null)
		else:
			report("Scene exists: " + name, false, "Not found")

func test_critical_scripts():
	print("\n--- Critical Scripts ---")
	var scripts: Array[String] = [
		"res://GlobalRegistry.gd",
		"res://Game/SaveManager.gd",
		"res://Game/BaseCharacter.gd",
		"res://Scenes/SceneBase.gd",
		"res://Systems/CrotchCode/CrotchTranspiler.gd",
		"res://Systems/CrotchCode/CrotchScriptBase.gd",
		"res://Systems/CrotchCode/CrotchCompiler.gd",
		"res://Systems/CrotchCode/CrotchGraphEditor.gd",
		"res://Util/AutoTranslation/AutoTranslation.gd",
		"res://Autoloads/EventBus.gd",
		"res://Core/ServiceLocator.gd",
		"res://Core/RegistryManager.gd",
		"res://Game/GM.gd",
		"res://Util/SexToySupport/SexToyManager.gd",
	]
	for script_path in scripts:
		var name: String = script_path.get_file()
		if ResourceLoader.exists(script_path):
			var gdscript = load(script_path)
			report("Script loads: " + name, gdscript != null)
		else:
			report("Script exists: " + name, false, "Not found")

func test_critical_resources():
	print("\n--- Critical Resources ---")
	var resources: Array[String] = [
		"res://GlobalTheme.tres",
		"res://default_env.tres",
		"res://UI/FontResources/Normal/NormalFont.tres",
		"res://UI/FontResources/Normal/BoldFont.tres",
	]
	for res_path in resources:
		var name: String = res_path.get_file()
		if ResourceLoader.exists(res_path):
			var res = load(res_path)
			report("Resource loads: " + name, res != null)
		else:
			report("Resource exists: " + name, false, "Not found")

func test_no_godot3_patterns():
	print("\n--- Godot 3 API Patterns ---")
	var forbidden: Array[String] = [
		"PoolByteArray", "PoolStringArray", "PoolIntArray",
		"PoolColorArray", "PoolVector2Array", "PoolVector3Array",
		"yield(", "extends Spatial", "extends Reference",
	]
	var key_files: Array[String] = [
		"res://GlobalRegistry.gd", "res://Game/BaseCharacter.gd",
		"res://Scenes/SceneBase.gd", "res://Systems/CrotchCode/CrotchTranspiler.gd",
		"res://Autoloads/EventBus.gd",
	]
	for path in key_files:
		if not ResourceLoader.exists(path):
			continue
		var content: String = FileAccess.get_file_as_string(path)
		if content.is_empty():
			continue
		for pattern in forbidden:
			if content.contains(pattern):
				report("No '" + pattern + "' in " + path.get_file(), false, "Found in " + path)
				return
	report("No Godot 3 patterns in key files", true)

func test_autoload_scripts():
	print("\n--- Autoload Scripts ---")
	var autoloads: Array[String] = [
		"res://Autoloads/EventBus.gd",
		"res://Core/ServiceLocator.gd",
		"res://Core/RegistryManager.gd",
		"res://Util/AutoTranslation/AutoTranslation.gd",
		"res://Game/Options/GlobalOptions.gd",
		"res://Game/GM.gd",
		"res://Util/SexToySupport/SexToyManager.gd",
		"res://Util/Log.gd",
		"res://Util/Util.gd",
		"res://Game/Datapacks/UI/CrotchCode/Util/CrotchFavBlocks.gd",
	]
	for a in autoloads:
		var name: String = a.get_file()
		if ResourceLoader.exists(a):
			var gdscript = load(a)
			if gdscript != null:
				var cls_name: String = gdscript.get_global_name()
				report("Autoload loads: " + name + " (class=" + cls_name + ")", true)
			else:
				report("Autoload exists: " + name, false, "load() returned null")
		else:
			report("Autoload exists: " + name, false, "Not found")

func print_summary():
	var line: String = "=".repeat(40)
	print("\n" + line)
	print("RESULTS: ", passed, " passed, ", failed, " failed")
	if error_list.size() > 0:
		print("\nFailed tests:")
		for e in error_list:
			print("  - ", e)
	print(line)
