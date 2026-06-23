extends SpinBox

var id

signal onValueChanged(id, newVal)

func setValue(theValue):
	value = theValue

func _on_VisRawInt_value_changed(value):
	onValueChanged.emit(id, value)
