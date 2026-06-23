extends VBoxContainer

## MIGRATED to Godot 4 (GDScript 2.0).
## Player info panel with 3D viewport, stat bars, camera controls.

@onready var grid: Control = $FlexGridContainer
@onready var name_label: Label = $NameLabel
@onready var credits_label: Label = $CreditsLabel
@onready var camera_3d: Camera3D = $ViewportWrapper/Viewport/Camera
@onready var stage_3d = $ViewportWrapper/Viewport/Stage3D
@onready var viewport = $ViewportWrapper/Viewport
@onready var stamina_bar = $StaminaBar
@onready var pain_bar = $PainBar
@onready var lust_bar = $HBoxContainer/LustBar
@onready var level_bar = $LevelBar
@onready var consciousness_bar = $ConsciousnessBar
@onready var arousal_bar = $HBoxContainer/ArousalBar

var previous_position: Vector2 = Vector2.ZERO
var start_mouse_position: Vector2 = Vector2.ZERO
var dragging_camera: bool = false
var mouse_inside_viewport: bool = false
var saved_tooltip_doll = null
var saved_tooltip_bodypart_slot = null
var touch_points: Dictionary = {}

func _ready() -> void:
	set_process_input(true)
	set_process_unhandled_input(true)
	camera_3d.current = true

func loading_savefile_finished() -> void:
	update_ui()

func on_player_stat_change() -> void:
	update_ui()

func update_ui() -> void:
	name_label.text = GM.pc.getName() + ", " + GM.pc.getSpeciesFullName()
	credits_label.text = "Work Credits: " + str(GM.pc.getCredits())
	pain_bar.setProgressBarValueInt(GM.pc.getPain(), GM.pc.painThreshold())
	pain_bar.setText(str(GM.pc.getPain()) + " / " + str(GM.pc.painThreshold()))
	lust_bar.setProgressBarValueInt(GM.pc.getLust(), GM.pc.lustThreshold())
	lust_bar.setText(str(GM.pc.getLust()) + " / " + str(GM.pc.lustThreshold()))
	stamina_bar.setProgressBarValueInt(GM.pc.getStamina(), GM.pc.getMaxStamina())
	stamina_bar.setText(str(GM.pc.getStamina()) + " / " + str(GM.pc.getMaxStamina()))
	level_bar.setProgressBarValue(GM.pc.getSkillsHolder().getLevelProgress())
	level_bar.setText(str(GM.pc.getSkillsHolder().getLevel()))

	var arousal = GM.pc.getArousal()
	if arousal > 0.0:
		arousal_bar.visible = true
		arousal_bar.setProgressBarValue(arousal)
		arousal_bar.setText(str(Util.roundF(arousal * 100.0)) + "%")
		lust_bar.setText(str(Util.roundF(GM.pc.getLustLevel() * 100.0)) + "%")
	else:
		arousal_bar.visible = false
		arousal_bar.setProgressBarValue(0.0)

	var consciousness = GM.pc.getConsciousness()
	if consciousness < 1.0:
		level_bar.visible = false
		consciousness_bar.visible = true
		consciousness_bar.setProgressBarValue(consciousness)
		consciousness_bar.setText(str(Util.roundF(consciousness * 100.0)) + "%")
	else:
		level_bar.visible = true
		consciousness_bar.visible = false
		consciousness_bar.setProgressBarValue(1.0)

func _gui_input(event: InputEvent) -> void:
	# Godot 4: MOUSE_MOUSE_BUTTON_MIDDLE, MOUSE_MOUSE_BUTTON_WHEEL_UP/DOWN
	if event is InputEventMouseButton and event.button_index == MOUSE_MOUSE_BUTTON_MIDDLE:
		camera_3d.size = 10
		camera_3d.transform.origin = Vector3(0.0, 4.141, 50.0)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_MOUSE_BUTTON_WHEEL_UP:
			camera_3d.size *= 0.9
		if event.button_index == MOUSE_MOUSE_BUTTON_DOWN:
			camera_3d.size *= 1.1

	if event is InputEventMouseButton:
		if event.pressed:
			dragging_camera = true
			start_mouse_position = event.position
			previous_position = event.position
		else:
			dragging_camera = false
	elif touch_points.size() <= 1 and dragging_camera and event is InputEventMouseMotion:
		var delta = previous_position - event.position
		camera_3d.translate(Vector3(delta.x * camera_3d.size / 500.0, -delta.y * camera_3d.size / 500.0, 0.0))
		previous_position = event.position

	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _on_ViewportContainer_mouse_exited() -> void:
	mouse_inside_viewport = false

func _on_ViewportContainer_mouse_entered() -> void:
	mouse_inside_viewport = true

func get_status_effects_panel() -> Control:
	return grid

func get_stage_3d():
	return stage_3d

func _on_ViewportWrapper_gui_input(event: InputEvent) -> void:
	_gui_input(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)

func _handle_drag(event: InputEventScreenDrag) -> void:
	if touch_points.size() == 2:
		var pivot_index: int = -1
		for finger_index in touch_points:
			if finger_index != event.index:
				pivot_index = finger_index
				break
		if pivot_index < 0:
			return
		var pivot_point: Vector2 = touch_points[pivot_index]
		var old_point: Vector2 = touch_points[event.index]
		var new_point: Vector2 = event.position
		var old_vector: Vector2 = old_point - pivot_point
		var new_vector: Vector2 = new_point - pivot_point
		var delta_scale := new_vector.length() / old_vector.length()
		camera_3d.size *= delta_scale
		touch_points[event.index] = new_point
		var drag_vector: Vector2 = event.relative
		camera_3d.translate(Vector3(drag_vector.x * camera_3d.size / 500.0, -drag_vector.y * camera_3d.size / 500.0, 0.0))
