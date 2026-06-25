extends RefCounted
class_name GameParser

## MIGRATED to Godot 4 (GDScript 2.0).
## Game text parser with gender/character commands.

func callFunc(_command: String, _args: Array) -> Variant:
	var should_be_upper := false
	if _command.length() > 0 and _command[0].to_upper() == _command[0]:
		should_be_upper = true
		_command[0] = _command[0].to_lower()
	var result = callFuncWrapper(_command, _args)
	if result is String and should_be_upper and result.length() > 0:
		result[0] = result[0].to_upper()
	return result

func callFuncWrapper(_command: String, _args: Array) -> Variant:
	if _command == "sayMale" and _args.size() == 1:
		return Util.sayMale(str(_args[0]))
	if _command == "sayFemale" and _args.size() == 1:
		return Util.sayFemale(str(_args[0]))
	if _command == "sayAndro" and _args.size() == 1:
		return Util.sayAndro(str(_args[0]))
	if _command == "sayOther" and _args.size() == 1:
		return Util.sayOther(str(_args[0]))
	if _command == "sayPlayer" and _args.size() == 1:
		return Util.sayPlayer(str(_args[0]))
	if _command == "pick":
		return str(RNG.pick(_args))
	if _command in ["penis", "cock", "dick"]:
		return RNG.pick(["cock", "dick", "member"])
	if _command in ["vagina", "pussy"]:
		return RNG.pick(["pussy", "cunt", "vagina"])
	if _command in ["ass", "butt"]:
		return RNG.pick(["ass", "butt"])
	if _command in ["asshole", "tailhole", "butthole", "anus"]:
		return RNG.pick(["asshole", "tailhole", "anus"])
	if _command == "rahiMaster":
		return ServiceLocator.safe_get_service(&"MainScene").getFlag("RahiModule.rahiPCName", ServiceLocator.safe_get_service(&"Player").getName())
	if _command == "taviCorruption":
		return str(Util.roundF(ServiceLocator.safe_get_service(&"MainScene").getFlag("TaviModule.Ch6Corruption", 1.0) * 100.0, 1)) + "%"
	return "[color=red]!RUNTIME ERROR NO COMMAND FOUND " + _command + " " + str(_args) + "![/color]"

func callObjectFunc(_obj: String, _command: String, _args: Array, overrides: Dictionary = {}) -> String:
	if overrides.has(_obj):
		_obj = overrides[_obj]
	var should_be_upper := false
	if _command.length() > 0 and _command[0].to_upper() == _command[0]:
		should_be_upper = true
		_command[0] = _command[0].to_lower()
	var result: String = callObjectFuncWrapper(_obj, _command, _args)
	if should_be_upper and result.length() > 0:
		result[0] = result[0].to_upper()
	return result

func callObjectFuncWrapper(_obj: String, _command: String, _args: Array) -> String:
	var resolved_name = ServiceLocator.safe_get_service(&"MainScene").resolveCustomCharacterName(_obj)
	if resolved_name != null:
		_obj = resolved_name
	var object = null
	if _obj == "pc":
		object = ServiceLocator.safe_get_service(&"Player")
	else:
		object = GlobalRegistry.getCharacter(_obj)
	if object == null:
		return "[color=red]!CHARACTER NOT FOUND " + _obj + "![/color]"
	if not object.has_method(_command):
		return "[color=red]!NO METHOD " + _command + " ON " + _obj + "![/color]"
	return str(object.callv(_command, _args))

func executeString(text: String, _overrides: Dictionary = {}) -> String:
	var result := _executeStringInternal(text)
	return result

func _executeStringInternal(text: String) -> String:
	# Simplified parser - full implementation in original
	return text
