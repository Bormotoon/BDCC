extends Control

signal onBlockDraggedOnto(data, index)

var dropIndex = -1

func can_drop_data(_position, _data):
	#setIsHighlighted(true)
	return true

func drop_data(_position, _data):
	onBlockDraggedOnto.emit(_data, dropIndex)

func _ready():
	custom_minimum_size.y = OPTIONS.getBlockCatcherPanelHeight()
	#var _ok = GlobalSignals.onDragEnded.connect(onDragEnded)
	#var _ok2 = GlobalSignals.onDragStarted.connect(onDragStarted)
