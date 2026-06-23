extends MarginContainer

var is_active := false setget set_is_active
export var showBelow = false

@onready var _tween := $Tween
@onready var _title := $VBoxContainer/Title
@onready var _body := $VBoxContainer/Body


func _ready() -> void:
	modulate = Color.transparent
	set_is_active(false)


func _process(_delta: float) -> void:
	if(showBelow):
		rect_global_position = get_global_mouse_position() - Vector2(size.x/2.0, 0) + rect_pivot_offset
	else:
		rect_global_position = get_global_mouse_position() - Vector2(size.x/2.0, size.y) - rect_pivot_offset
	rect_global_position.x = max(10, rect_global_position.x)
	rect_global_position.x = min(get_viewport_rect().size.x - 10 - size.x, rect_global_position.x)
	rect_global_position.y = max(10, rect_global_position.y)
	rect_global_position.y = min(get_viewport_rect().size.y - 10 - size.y, rect_global_position.y)
	#rect_global_position.x = clamp(rect_global_position.x, 0, ProjectSettings.get("display/window/size/width") - size.x)
	#rect_global_position.y = clamp(rect_global_position.y, 0, ProjectSettings.get("display/window/size/height") - size.y)

func setIsWide(newWide: bool):
	if(newWide):
		rect_min_size.x = 500
	else:
		rect_min_size.x = 250

func set_is_active(value: bool, delayShow = false):
	is_active = value
	set_process(is_active)

	if is_active:
		if(delayShow):
			_tween.remove_all()
			_tween.interpolate_property(self, "modulate", Color(0.0, 0.0, 0.0, -6.0), Color.white, 0.6)
			_tween.start()
		else:
			modulate = Color.white
			_tween.remove_all()
	else:
		_tween.remove_all()
		_tween.interpolate_property(self, "modulate", modulate, Color.transparent, 0.2)
		_tween.start()

func is_tooltip_active():
	return is_active

func set_text(title: String, body: String):
	_title.text = title.capitalize()
	_body.bbcode_text = body
	#await get_tree().process_frame
	#_body.set_size(Vector2(_body.get_size().x, _body.get_v_scroll().get_max()))
	await get_tree().process_frame
	size.y = 0
	size.x = 0
	#_body.set_size(Vector2(_body.get_size().x, _body.get_v_scroll().get_max()))
	#await get_tree().process_frame
	
	#size = Vector2(0,0)
	#_body.size = Vector2(0,0)
	#$VBoxContainer.size = Vector2(250,0)

func setShowBelow(shbelow):
	showBelow = shbelow
