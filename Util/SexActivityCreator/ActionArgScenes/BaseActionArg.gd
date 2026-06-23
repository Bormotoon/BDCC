extends Control

var id = "error"
var valueID = ""
var dataID = ""

signal onChange(dataID, data)

func setData(_data):
	pass

func getData():
	return {}

func setText(_newText):
	pass

func setOptions(_options):
	pass

func emitChanged():
	onChange.emit(dataID, getData())
