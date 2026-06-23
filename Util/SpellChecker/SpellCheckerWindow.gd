extends WindowDialog

@onready var spell_checker_test = $SpellCheckerTest

signal onTextSubmit(window, newText)
signal onCancel(window)

func setText(theText:String):
	spell_checker_test.setTextAndCheck(theText)

func _on_SpellCheckerTest_onCancel():
	onCancel.emit(self)

func _on_SpellCheckerTest_onTextSubmit(newText):
	onTextSubmit.emit(self, newText)

func _on_SpellCheckerWindow_popup_hide():
	onCancel.emit(self)
