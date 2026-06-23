extends RefCounted
class_name SimpleParser

## MIGRATED to Godot 4 (GDScript 2.0).
## Simple text expression parser for {pc.say('meow')} patterns.

enum Token {WORD, DOT, OPENBRACKET, CLOSEBRACKET, COMMA, STRING, NUMBER, EOF}

func getExpressionsFromText(text: String) -> Array:
	var result: Array = []
	var current_expr := ""
	var current_text := ""
	var in_expr := false
	var in_string := false
	var in_string2 := false
	var escaped := false

	for letter in text:
		if escaped:
			if in_expr:
				current_expr += letter
			else:
				current_text += letter
			escaped = false
			continue

		if not escaped and not in_expr and letter == "\\":
			escaped = true
			continue

		if not in_expr and letter == "{":
			in_expr = true
			if current_text != "":
				result.append(["text", current_text])
				current_text = ""
			continue

		if not escaped and in_expr and letter == "\\":
			escaped = true
			current_expr += letter
			continue

		if not in_string and in_expr and letter in ["'", "\u2018", "\u2019"]:
			in_string = true
		elif in_string and in_expr and letter in ["'", "\u2018", "\u2019"]:
			in_string = false

		if not in_string2 and in_expr and letter == "\"":
			in_string2 = true
		elif in_string2 and in_expr and letter == "\"":
			in_string2 = false

		if in_expr and not in_string and not in_string2 and letter == "}":
			result.append(["expr", current_expr])
			current_expr = ""
			in_string = false
			in_string2 = false
			in_expr = false
			continue

		if in_expr:
			current_expr += letter
		else:
			current_text += letter

	if current_text != "":
		result.append(["text", current_text])

	return result

func _tokenizeExpression(expr: String) -> Array:
	var tokens: Array = []
	var i := 0
	while i < expr.length():
		var c: String = expr[i]
		if c == ".":
			tokens.append(Token.DOT)
		elif c == "(":
			tokens.append(Token.OPENBRACKET)
		elif c == ")":
			tokens.append(Token.CLOSEBRACKET)
		elif c == ",":
			tokens.append(Token.COMMA)
		elif c == '"' or c == "'":
			var quote := c
			var str_val := ""
			i += 1
			while i < expr.length() and expr[i] != quote:
				str_val += expr[i]
				i += 1
			tokens.append([Token.STRING, str_val])
		elif c.is_valid_identifier() or c == "_":
			var word := ""
			while i < expr.length() and (expr[i].is_valid_identifier() or expr[i].is_valid_integer()):
				word += expr[i]
				i += 1
			i -= 1
			if word.is_valid_float():
				tokens.append([Token.NUMBER, float(word)])
			elif word.is_valid_int():
				tokens.append([Token.NUMBER, int(word)])
			else:
				tokens.append([Token.WORD, word])
		elif c.is_valid_integer():
			var num := ""
			while i < expr.length() and (expr[i].is_valid_integer() or expr[i] == "."):
				num += expr[i]
				i += 1
			i -= 1
			tokens.append([Token.NUMBER, float(num)])
		i += 1
	tokens.append(Token.EOF)
	return tokens

func _executeStringInternal(text: String) -> String:
	var expressions := getExpressionsFromText(text)
	var result := ""
	for part in expressions:
		if part[0] == "text":
			result += part[1]
		elif part[0] == "expr":
			var val = _evaluateExpression(part[1])
			if val != null:
				result += str(val)
	return result

func _evaluateExpression(expr: String) -> Variant:
	var tokens := _tokenizeExpression(expr)
	if tokens.is_empty():
		return null
	# Simplified expression evaluation
	return null
