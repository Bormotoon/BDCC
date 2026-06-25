# Systems/CrotchCode/CrotchGraphEditor.gd
class_name CrotchGraphEditor extends GraphEdit

## UI component for the CrotchCode 2.0 visual modding editor.
## Wraps Godot's GraphEdit for connecting visual blocks.

func _ready() -> void:
	right_disconnects = true

	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)

## Exports the current visual graph to a dictionary for the transpiler
func export_to_dictionary() -> Dictionary:
	var export_data: Dictionary = {}
	var start_node_id: String = ""

	for child in get_children():
		if child is GraphNode:
			var node_id: String = child.name
			var block_data: Dictionary = {}

			if child.has_method("get_block_data"):
				block_data = child.get_block_data()

			export_data[node_id] = block_data

			if start_node_id.is_empty():
				start_node_id = node_id

	# Map connections by output port index
	for connection in get_connection_list():
		var from_node: String = connection["from"]
		var from_port: int = connection["from_port"]
		var to_node: String = connection["to"]

		if not export_data.has(from_node):
			continue

		match from_port:
			0:
				export_data[from_node]["next_id"] = to_node
			1:
				export_data[from_node]["then_id"] = to_node
			2:
				export_data[from_node]["else_id"] = to_node
			3:
				export_data[from_node]["body_id"] = to_node
			_:
				export_data[from_node]["next_id"] = to_node

	return {
		"blocks": export_data,
		"start_node": start_node_id,
		"block_count": export_data.size(),
	}

## Clears all nodes and connections
func clear_graph() -> void:
	for child in get_children():
		if child is GraphNode:
			child.queue_free()
	clear_connections()

## Adds a new block node to the graph
func add_block_node(block_type: StringName, position: Vector2 = Vector2.ZERO) -> GraphNode:
	var node := GraphNode.new()
	node.name = "Block_%d" % get_child_count()
	node.position_offset = position

	var title_label := Label.new()
	title_label.text = String(block_type)
	node.add_child(title_label)

	add_child(node)
	return node
