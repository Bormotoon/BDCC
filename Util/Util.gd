extends Object
class_name Util

## MIGRATED to Godot 4 (GDScript 2.0).
## General utility functions. Directory→DirAccess, File→FileAccess.

static func fixed_shell_open(string: String):
	var os_name = OS.get_name()
	if string.begins_with("https://"):
		return OS.shell_open(string)
	elif os_name == "macOS" and string.begins_with("/"):
		return OS.shell_open("file://" + string)
	else:
		return OS.shell_open(string)

static func delete_children(node: Node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

static func remove_all_signals(node: Node) -> void:
	var signals = node.get_signal_list()
	for cur_signal in signals:
		var conns = node.get_signal_connection_list(cur_signal.name)
		for cur_conn in conns:
			node.disconnect(cur_conn.signal, cur_conn.target, cur_conn.method)

static func maxi(value1: int, value2: int) -> int:
	return max(value1, value2)

static func mini(value1: int, value2: int) -> int:
	return min(value1, value2)

static func uniqueElements(arr: Array) -> Array:
	var saw: Dictionary = {}
	var result: Array = []
	for element in arr:
		if not saw.has(element):
			saw[element] = true
			result.append(element)
	return result

static func humanReadableList(arr: Array, and_connector: String = "and", comma_connector: String = ",") -> String:
	var arr_size := arr.size()
	if arr_size == 0:
		return ""
	if arr_size == 1:
		return str(arr[0])
	if arr_size == 2:
		return str(arr[0]) + " " + and_connector + " " + str(arr[1])
	var res := ""
	for i in range(arr_size):
		if i == arr_size - 1:
			res += " " + and_connector + " "
		res += str(arr[i])
		if i <= arr_size - 3:
			res += comma_connector + " "
	return res

## Directory→DirAccess (line 81-96)
static func getFilesInFolder(folder: String) -> Array:
	var result: Array = []
	var dir := DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				result.append(folder.path_join(file_name))
			file_name = dir.get_next()
	else:
		Log.printerr("Cannot access path " + folder)
	return result

## Recursive file listing (line 98-119)
static func getFilesInFoldersRecursive(folder: String, ignore_base_dir: bool = false) -> Array:
	var result: Array = []
	var dir := DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var full_path := folder.path_join(file_name)
				result.append_array(getFilesInFoldersRecursive(full_path, false))
			else:
				if not ignore_base_dir:
					result.append(folder.path_join(file_name))
			file_name = dir.get_next()
	return result

## Array joining (lines 122-141)
static func join(arr: Array, separator: String = "") -> String:
	var output := ""
	for s in arr:
		output += str(s) + separator
	return output.left(output.length() - separator.length())

## Time formatting (lines 145-182)
static func getTimeStringHumanReadable(t) -> String:
	var _seconds := floorf(fmod(float(t), 60.0))
	var _minutes := floorf(fmod(float(t) / 60.0, 60.0))
	var _hours := floorf(fmod(float(t) / 3600.0, 24.0))
	var _days := floorf(float(t) / (3600.0 * 24.0))
	var result := ""
	if _days > 0:
		result += str(_days) + " days "
	if _hours > 0:
		result += str(_hours) + "h "
	if _minutes > 0:
		result += str(_minutes) + "m "
	if _seconds > 0 or result.is_empty():
		result += str(_seconds) + "s "
	return result.trim_suffix(" ")

static func getTimeStringHHMMSS(t) -> String:
	var _seconds := floorf(fmod(float(t), 60.0))
	var _minutes := floorf(fmod(float(t) / 60.0, 60.0))
	var _hours := floorf(float(t) / 3600.0)
	return "%02d:%02d:%02d" % [_hours, _minutes, _seconds]

static func getTimeStringHHMM(t) -> String:
	var _seconds := floorf(fmod(float(t), 60.0))
	var _minutes := floorf(fmod(float(t) / 60.0, 60.0))
	var _hours := floorf(float(t) / 3600.0)
	return "%02d:%02d" % [_hours, _minutes]

## Math utilities (lines 206-220)
static func roundF(number: float, digits_amount: int = 0) -> float:
	var mult := 1.0
	for _i in range(digits_amount):
		mult *= 10.0
	return roundf(number * mult) / mult

static func moveNumberTowards(orig: float, target: float, speed: float) -> float:
	var delta := target - orig
	delta = clampf(delta, -speed, speed)
	return orig + delta

## Species name (line 222-241)
static func getSpeciesName(species: Array) -> String:
	if species.is_empty():
		return "Unknown species"
	if species.size() == 1:
		var specie = GlobalRegistry.getSpecies(species[0])
		return specie.getVisibleName() if specie else "Unknown species"
	var names: Array = []
	for specie_id in species:
		var specie = GlobalRegistry.getSpecies(specie_id)
		names.append(specie.getVisibleName() if specie else "Unknown species")
	return join(names, "-") + " hybrid"

## File modified time (line 250-261)
static func getFileModifiedTime(path: String, correct_timezone: bool = true) -> int:
	var file_mod_time := FileAccess.get_modified_time(path)
	if file_mod_time > 100000000000:
		file_mod_time = file_mod_time / 1000
	if correct_timezone:
		var tz: Dictionary = Time.get_time_zone_from_system()
		file_mod_time += int(tz["bias"]) * 60
	return file_mod_time

## String helpers
static func isBitEnabled(value: int, bit: int) -> bool:
	return (value >> bit) & 1 == 1

static func stripBadFilenameCharacters(text: String) -> String:
	var result := text
	for c in ["\\", "/", ":", "*", "?", "\"", "<", ">", "|"]:
		result = result.replace(c, "_")
	return result

static func stripBadCharactersFromID(text: String) -> String:
	return stripBadFilenameCharacters(text)

static func variantTypeToString(type_id: int) -> String:
	match type_id:
		TYPE_NIL: return "null"
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "String"
		TYPE_DICTIONARY: return "Dictionary"
		TYPE_ARRAY: return "Array"
	return "unknown"

static func cmToString(cm: float) -> String:
	return str(roundF(cm * 10.0, 1)) + " cm"
