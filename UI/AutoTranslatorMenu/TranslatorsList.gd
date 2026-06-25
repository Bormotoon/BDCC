extends VBoxContainer

@onready var translatorList = $ScrollContainer/TranslatorList

@export var labelText = "Some text"
@export var smallContainer = true

signal onUpPressed(id)
signal onDownPressed(id)

var translators = []

var translatorItemScene = preload("res://UI/AutoTranslatorMenu/TranslatorItem.tscn")

func _ready():
	if(smallContainer):
		$ScrollContainer.custom_minimum_size.y = 100
	else:
		$ScrollContainer.custom_minimum_size.y = 200

func clearTranslators():
	translators.clear()
	updateTranslators()

func addTranslator(text):
	translators.append(text)
	updateTranslators()

func updateTranslators():
	Util.delete_children(translatorList)

	var _i = 0
	for translator in translators:
		var newItem = translatorItemScene.instantiate()
		translatorList.add_child(newItem)
		newItem.setText(translator)
		newItem.id = _i
		_i += 1

		newItem.onUpButton.connect(onTranslatorUpPressed)
		newItem.onDownButton.connect(onTranslatorDownPressed)

func onTranslatorUpPressed(id, _data):
	if id == 0:
		return
	var modified = translators.pop_at(id)
	translators.insert(id - 1, modified)
	updateTranslators()
	onUpPressed.emit(id)
func onTranslatorDownPressed(id, _data):
	if id == len(translators) - 1:
		return
	
	var modified = translators.pop_at(id)
	translators.insert(id + 1, modified)
	updateTranslators()
	onDownPressed.emit(id)
