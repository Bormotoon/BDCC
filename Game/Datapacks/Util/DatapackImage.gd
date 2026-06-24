extends RefCounted
class_name DatapackImage

var image:Image
var imageRaw:PackedByteArray
var texture:ImageTexture

func isEmpty() -> bool:
	return getImage() == null

func getImage() -> Image:
	if(image != null):
		return image
	
	if(imageRaw.is_empty()):
		return image
	var newIm = Image.new()
	var _ok = newIm.load_png_from_buffer(imageRaw)
	if(_ok == OK):
		image = newIm
		imageRaw = PackedByteArray()
	return image

func setImage(newIm:Image):
	if(image == newIm):
		return
	image = newIm
	imageRaw = PackedByteArray()
	texture = null

func getTexture() -> ImageTexture:
	if(texture == null):
		if(getImage() != null):
			texture = ImageTexture.new()
			texture.create_from_image(getImage())
	return texture

func saveData() -> PackedByteArray:
	return (getImage().save_png_to_buffer() if getImage() else PackedByteArray())

func loadData(_data):
	if(!(_data is PackedByteArray)):
		setImage(null)
		return
	imageRaw = _data
	image = null
	texture = null
