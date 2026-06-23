extends RefCounted
class_name CrotchSlotCalls

var blocks = []

signal onBlockAdded(newBlock, index)
signal onBlockRemoved(oldBlock)
signal onBlockClear

func clear():
	blocks = []
	onBlockClear.emit()

func addBlock(newBlock):
	blocks.append(newBlock)
	onBlockAdded.emit(newBlock, blocks.size() - 1)

func removeBlock(theBlock):
	blocks.erase(theBlock)
	onBlockRemoved.emit(theBlock)

func execute(_contex:CodeContex):
	for block in blocks:
		block.execute(_contex)
		if(_contex.hadAnError()):
			_contex.resetErrored()
		if(_contex.shouldReturn()):
			return

func getBlocks():
	return blocks

func addBlockAt(newBlock, index):
	blocks.insert(index, newBlock)
	onBlockAdded.emit(newBlock, index)

func calcLineNums(_contex:CodeContex):
	for block in blocks:
		_contex.curLine += 1
		block.calcLineNums(_contex)

func saveData():
	var data = {}
	
	var blocksData = []
	for block in blocks:
		blocksData.append({
			id = block.id,
			data = block.saveData(),
		})
	data["blocks"] = blocksData
	
	return data

func loadData(_data):
	clear()
	var blocksData = loadVar(_data, "blocks", [])
	for blockData in blocksData:
		var theID = loadVar(blockData, "id", "")
		var theBlock = CrotchBlocks.createBlock(theID)
		if(theBlock != null):
			theBlock.loadData(loadVar(blockData, "data", {}))
			addBlock(theBlock)
	
func loadVar(_data, thekey, defaultValue = null):
	if(_data.has(thekey)):
		return _data[thekey]
	return defaultValue
