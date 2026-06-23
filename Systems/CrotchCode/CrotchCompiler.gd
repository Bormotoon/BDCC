# Systems/CrotchCode/CrotchCompiler.gd
class_name CrotchCompiler extends RefCounted

## Migrated from CodeContex.gd runtime execution.
## Compiles transpiled GDScript source code into executable objects at runtime.

## Compiles source code and returns a CrotchScriptBase instance
func compile_and_instantiate(source_code: String) -> CrotchScriptBase:
	var script := GDScript.new()
	script.source_code = source_code

	var error := script.reload()
	if error != OK:
		push_error("CrotchCompiler: Compilation error! Error code: %d" % error)
		push_error("Source code:\n%s" % source_code)
		return null

	var instance = script.new()
	if instance is CrotchScriptBase:
		return instance as CrotchScriptBase
	else:
		push_error("CrotchCompiler: Generated script does not extend CrotchScriptBase!")
		return null

## Compiles and executes in one step
func compile_and_execute(source_code: String) -> bool:
	var instance := compile_and_instantiate(source_code)
	if instance == null:
		return false

	instance.execute()
	return true

## Validates source code without executing (for editor preview)
func validate_source(source_code: String) -> Dictionary:
	var script := GDScript.new()
	script.source_code = source_code

	var error := script.reload()
	return {
		"success": error == OK,
		"error_code": error,
		"error_message": error_string(error) if error != OK else "",
	}
