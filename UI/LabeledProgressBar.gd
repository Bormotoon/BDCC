extends PanelContainer

@export var colorGradient: Gradient
@export var propertyName = "Property"
var currentValue = null
var currentBarValue = 0.0

func _ready():
	$ProgressBar.value = 0
	$MarginContainer/HBoxContainer/Label.text = propertyName

func setTextLeft(leftText):
	$MarginContainer/HBoxContainer/Label.text = leftText

func setText(rightText):
	$MarginContainer/HBoxContainer/Label2.text = rightText

func setProgressBarValue(value):
	if(currentValue == value):
		return
	
	currentValue = value
	var tween := create_tween()
	tween.tween_method(updateBarValue, currentBarValue, currentValue, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func updateBarValue(value):
	$ProgressBar.value = value
	#$ProgressBar.get("custom_styles/fg").set_bg_color(colorEmpty.lerp(colorFull, value))
	$ProgressBar.get("custom_styles/fg").set_bg_color(colorGradient.interpolate(value))
	currentBarValue = value

func setProgressBarValueInt(value, maxvalue):
	var fvalue = float(value)
	var fmaxvalue = float(maxvalue)
	
	if(fmaxvalue == 0.0):
		return
	
	var ffvalue = fvalue/fmaxvalue
	setProgressBarValue(ffvalue)

func resetToZero():
	currentBarValue = 0.0
	$ProgressBar.value = 0.0
