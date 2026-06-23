# Simulation/SimulationBridge.gd
class_name SimulationBridge extends Node

## Bridge between GDScript events and C# simulation engine.
## Initializes the C# node and forwards signals to it.

var csharp_engine: Node
var room_graph: RoomGraph

func _ready() -> void:
	var CSharpScript = load("res://Simulation/SimulationEngine.cs")
	csharp_engine = CSharpScript.new()
	add_child(csharp_engine)

	room_graph = RoomGraph.new()

	ServiceLocator.register_service(&"SimulationBridge", self)

	EventBus.time_advanced.connect(_on_time_advanced)
	EventBus.npc_spawned.connect(_on_npc_spawned)

func _on_time_advanced(minutes: int) -> void:
	if csharp_engine and csharp_engine.has_method("ProcessSimulationTick"):
		csharp_engine.ProcessSimulationTick(float(minutes))

func _on_npc_spawned(npc_id: StringName, room_id: StringName) -> void:
	if csharp_engine and csharp_engine.has_method("AddNpc"):
		csharp_engine.AddNpc(npc_id, room_id)
