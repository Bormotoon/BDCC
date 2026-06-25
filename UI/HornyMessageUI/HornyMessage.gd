extends Control

@onready var richTextLabel = $CanvasLayer/RichTextLabel

var _tween: Tween

func _ready():
	visible = false

func showMessageOnScreen(msg: String) -> void:
	visible = true
	if _tween and _tween.is_valid():
		richTextLabel.append_text(msg)
	else:
		richTextLabel.append_text(msg)
		_tween = create_tween()
		_tween.set_parallel(true)
		_tween.tween_property(richTextLabel, "visible_ratio", 1.0, 4.0).from(0.0)
		_tween.tween_property(richTextLabel, "scale", Vector2(1.8, 1.6), 6.0).from(Vector2(1.0, 1.0)).set_ease(Tween.EASE_IN_OUT)
		_tween.chain()
		_tween.set_parallel(false)
		_tween.tween_property(richTextLabel, "modulate:a", 0.0, 5.0).from(1.0).set_ease(Tween.EASE_IN_OUT)
		_tween.tween_callback(_on_tween_finished)

func _on_tween_finished():
	richTextLabel.clear()
	visible = false
