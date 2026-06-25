extends RefCounted
class_name SayParser

## MIGRATED to Godot 4 (GDScript 2.0).
## Dialogue tag parser for [say=pc]...[/say] commands.

enum TagType {Text, Tag, CloseTag}

func findTags(text: String) -> Array:
	var saved_text := ""
	var saved_tag := ""
	var result: Array = []
	var pos := 0
	while pos < text.length():
		if text[pos] == "[":
			pos += 1
			var is_close_tag := false
			if text[pos] == "/":
				is_close_tag = true
				pos += 1
			if saved_text != "":
				result.append([TagType.Text, saved_text])
				saved_text = ""
			while pos < text.length():
				if text[pos] == "]":
					if not is_close_tag:
						var arg_starts := saved_tag.find("=")
						var arg := ""
						if arg_starts >= 0:
							arg = saved_tag.substr(arg_starts + 1)
							saved_tag = saved_tag.substr(0, arg_starts)
						result.append([TagType.Tag, saved_tag, arg])
					else:
						result.append([TagType.CloseTag, saved_tag])
					saved_tag = ""
					pos += 1
					break
				else:
					saved_tag += text[pos]
					pos += 1
			if saved_tag != "":
				Log.err("findTags(): tag wasn't closed")
				result.append([TagType.Text, saved_tag])
				saved_tag = ""
		else:
			saved_text += text[pos]
			pos += 1
	if saved_text != "":
		result.append([TagType.Text, saved_text])
	return result

func combineTags(tags: Array) -> Array:
	var result: Array = []
	var pos := 0
	var process_these: Dictionary = {
		"say": true, "sayShowName": true, "sayMale": true,
		"sayFemale": true, "sayAndro": true, "sayOther": true,
	}
	while pos < tags.size():
		var tag = tags[pos]
		if tag[0] == TagType.Text:
			result.append(tag)
			pos += 1
		elif tag[0] == TagType.CloseTag:
			result.append([TagType.Text, "[/" + tag[1] + "]"])
			pos += 1
		elif tag[0] == TagType.Tag:
			if process_these.has(tag[1]):
				var tag_command := tag[1]
				var tag_arg: String = tag[2]
				var tag_text := ""
				pos += 1
				while pos < tags.size():
					if tags[pos][0] == TagType.Text:
						tag_text += tags[pos][1]
						pos += 1
					elif tags[pos][0] == TagType.CloseTag:
						if tags[pos][1] == tag_command or tags[pos][1] == "":
							result.append([TagType.Tag, tag_command, tag_arg, tag_text])
							pos += 1
							break
						else:
							tag_text += "[/" + tags[pos][1] + "]"
							pos += 1
					else:
						pos += 1
			else:
				if tag[2] == "":
					result.append([TagType.Text, "[" + tag[1] + "]"])
				else:
					result.append([TagType.Text, "[" + tag[1] + "=" + tag[2] + "]"])
				pos += 1
		else:
			pos += 1
	return result

func processString(text: String, overrides: Dictionary = {}) -> String:
	var tags := findTags(text)
	var combined := combineTags(tags)
	var result := ""
	for tag in combined:
		if tag[0] == TagType.Text:
			result += tag[1]
		if tag[0] == TagType.Tag:
			result += processTag(tag[1], tag[2], tag[3], overrides)
	return result

func processTag(tag: String, arg: String, text: String, overrides: Dictionary = {}) -> String:
	if tag in ["say", "sayShowName"]:
		if overrides.has(arg):
			arg = overrides[arg]
		var resolved_name = ServiceLocator.safe_get_service(&"MainScene").resolveCustomCharacterName(arg)
		if resolved_name != null:
			arg = resolved_name
		var object = null
		if arg == "pc":
			object = ServiceLocator.safe_get_service(&"Player")
		elif GlobalRegistry.getCharacter(arg) != null:
			object = GlobalRegistry.getCharacter(arg)
		if object == null:
			return "!Error: " + arg + " character not found!"
		var prefix := ""
		if OPTIONS.shouldShowSpeakerName() or tag == "sayShowName":
			prefix = "[b]" + object.getName() + "[/b]: "
		return prefix + object.formatSay(text)
	if tag == "sayMale":
		var prefix := "[b]Someone[/b]: " if OPTIONS.shouldShowSpeakerName() else ""
		return prefix + Util.sayMale(text)
	if tag == "sayFemale":
		var prefix := "[b]Someone[/b]: " if OPTIONS.shouldShowSpeakerName() else ""
		return prefix + Util.sayFemale(text)
	if tag == "sayAndro":
		var prefix := "[b]Someone[/b]: " if OPTIONS.shouldShowSpeakerName() else ""
		return prefix + Util.sayAndro(text)
	if tag == "sayOther":
		var prefix := "[b]Someone[/b]: " if OPTIONS.shouldShowSpeakerName() else ""
		return prefix + Util.sayOther(text)
	return "!" + tag + "=" + arg + ":" + text + "!"
