extends MarginContainer

var is_active := false:
	set(value):
		set_is_active(value)
var showBelow = false

@onready var _tween := $Tween
@onready var _title := $VBoxContainer/Title
@onready var _body := $VBoxContainer/Body


func _ready() -> void:
	modulate = Color.TRANSPARENT
	set_is_active(false)


func _process(_delta: float) -> void:
	if(showBelow):
		global_position = get_global_mouse_position() - Vector2(size.x/2.0, 0) + pivot_offset
	else:
		global_position = get_global_mouse_position() - Vector2(size.x/2.0, size.y) - pivot_offset
	global_position.x = max(10, global_position.x)
	global_position.x = min(get_viewport_rect().size.x - 10 - size.x, global_position.x)
	global_position.y = max(10, global_position.y)
	global_position.y = min(get_viewport_rect().size.y - 10 - size.y, global_position.y)
	#global_position.x = clamp(global_position.x, 0, ProjectSettings.get("display/window/size/width") - size.x)
	#global_position.y = clamp(global_position.y, 0, ProjectSettings.get("display/window/size/height") - size.y)

func setIsWide(newWide: bool):
	if(newWide):
		custom_minimum_size.x = 500
	else:
		custom_minimum_size.x = 250

func set_is_active(value: bool, delayShow = false):
	is_active = value
	set_process(is_active)

	if is_active:
		if(delayShow):
			_tween.remove_all()
			_tween.interpolate_property(self, "modulate", Color(0.0, 0.0, 0.0, -6.0), Color.WHITE, 0.6)
			_tween.start()
		else:
			modulate = Color.WHITE
			_tween.remove_all()
	else:
		_tween.remove_all()
		_tween.interpolate_property(self, "modulate", modulate, Color.TRANSPARENT, 0.2)
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
