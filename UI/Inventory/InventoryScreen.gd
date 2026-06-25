extends Control

@onready var itemListContainer = $MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer2/VBoxContainer
var inventoryEntry = preload("res://UI/Inventory/InventoryEntry.tscn")
var inventoryGroupEntry = preload("res://UI/Inventory/InventoryGroupEntry.tscn")
@onready var itemNameLabel = $MarginContainer/HBoxContainer/VBoxContainer/Label
@onready var itemDescLabel = $MarginContainer/HBoxContainer/VBoxContainer/RichTextLabel
@onready var searchInput = $MarginContainer/HBoxContainer/VBoxContainer2/ScrollContainer/VBoxContainer2/SearchLineEdit

#var inventory: Inventory
var itemsByGroup = {}
var selectedItem: ItemBase
var itemEntries = []
var filterEnteries = []

signal onInteractWith(item)
signal onInteractWithGroup(item)
signal onItemSelected(item)

var currentMode = ""
var isBuy = false
var isSell = false
var isLoot = false
var shouldGroup:bool = true

var shouldGrabInput = true

func _ready():
	if(shouldGrabInput && !DisplayServer.is_touchscreen_available()):
		searchInput.grab_focus()

#func setInventory(inv, isFight = false):
	#if(inventory != inv || isFightMode != isFight):
	#	isFightMode = isFight
	#	inventory = inv
	#	updateInventory()

func setItems(newItems, theMode = ""):
	currentMode = theMode
	itemsByGroup = newItems
	isBuy = (theMode == "buy")
	isSell = (theMode == "sell")
	isLoot = (theMode == "loot")
	updateInventory()
	filterInventory()

func filterInventory():
	var textToFilter = searchInput.text.to_lower()
	if(textToFilter == ""):
		for entry in filterEnteries:
			entry.visible = true
		return
	
	for entry in filterEnteries:
		var nameToCheck = entry.getItem().getVisibleName().to_lower()
		
		if(textToFilter in nameToCheck):
			entry.visible = true
		else:
			entry.visible = false

func updateInventory():
	Util.delete_children(itemListContainer)
	itemEntries = []
	filterEnteries = []
	
	#if(inventory == null):
	#	return
	
	var theItemsGrouped = itemsByGroup#inventory.getItemsAndEquippedItemsTogetherGrouped()
	if(shouldGroup):
		if(theItemsGrouped is Array):
			var newItemsGrouped = {}
			for item in theItemsGrouped:
				if(!item):
					continue
				if(!newItemsGrouped.has(item.id)):
					newItemsGrouped[item.id] = [item]
				else:
					newItemsGrouped[item.id].append(item)
			theItemsGrouped = newItemsGrouped
	else:
		if(theItemsGrouped is Array):
			var newItemsGrouped = {}
			for item in theItemsGrouped:
				if(!item):
					continue
				newItemsGrouped[item.id+"__"+str(item.uniqueID)] = [item]
			theItemsGrouped = newItemsGrouped
	
	# Items that we can use are first while in combat
	if(currentMode == "fight"):
		var newOrder = {}
		var lastItems = {}
		for itemKey in theItemsGrouped:
			var item = theItemsGrouped[itemKey][0]
			if(!item):
				continue
			var actions = item.getPossibleActions()
			if(actions.size() == 1):
				newOrder[itemKey] = theItemsGrouped[itemKey]
			else:
				lastItems[itemKey] = theItemsGrouped[itemKey]

		for itemKey in lastItems:
			newOrder[itemKey] = lastItems[itemKey]
		theItemsGrouped = newOrder
	
	for groupID in theItemsGrouped:
		var theItems = theItemsGrouped[groupID]
		
		if(theItems.size() == 1):
			var item = theItems[0]
			if(item):
				var entry = inventoryEntry.instantiate()
				itemListContainer.add_child(entry)
				itemEntries.append(entry)
				filterEnteries.append(entry)
				entry.setItem(item, currentMode)
				
				entry.onInteractButtonPressed.connect(onEntryInteractButtonPressed)
				entry.onItemSelected.connect(onEntrySelected)
		else:
			var newGroupEntry = inventoryGroupEntry.instantiate()
			itemListContainer.add_child(newGroupEntry)
			newGroupEntry.setItem(theItems[0], currentMode)
			filterEnteries.append(newGroupEntry)
			
			newGroupEntry.onInteractButtonPressed.connect(onGroupEntryInteractButtonPressed)
			# add entry to some group entries maybe here
			for item in theItems:
				if(!item):
					continue
				var entry = inventoryEntry.instantiate()
				newGroupEntry.addEntry(entry)
				entry.setItem(item, currentMode)
				itemEntries.append(entry)
				
				entry.onInteractButtonPressed.connect(onEntryInteractButtonPressed)
				entry.onItemSelected.connect(onEntrySelected)
			newGroupEntry.updateCollapsed()
			
	updateSelectedHighlight()

func updateSelectedHighlight():
	for entry in itemEntries:
		if(entry.getItem() == selectedItem):
			entry.setSelected(true)
		else:
			entry.setSelected(false)

func updateSelectedInfo():
	if(selectedItem == null):
		itemNameLabel.text = "Pick an item"
		itemDescLabel.text = ""
		return
	itemNameLabel.text = selectedItem.getStackName()
	itemDescLabel.text = selectedItem.getVisibleDescription()
	if(isBuy):
		var price = selectedItem.getPrice()
		var priceStr = (str(price)+" credit") if price == 1 else (str(price)+" credits")
		itemDescLabel.text += "\nPrice: " +priceStr
		if(selectedItem.getBuyAmount() > 1):
			itemDescLabel.text += " (for "+str(selectedItem.getBuyAmount())+")"
	if(isSell):
		var price = selectedItem.getStackSellPrice()
		var priceStr = (str(price)+" credit") if price == 1 else (str(price)+" credits")
		itemDescLabel.text += "\nPrice: " +priceStr
		if(selectedItem.getAmount() > 1):
			itemDescLabel.text += " (for "+str(selectedItem.getAmount())+")"

func onEntryInteractButtonPressed(theItem):
	onInteractWith.emit(theItem)

func onGroupEntryInteractButtonPressed(theItem):
	onInteractWithGroup.emit(theItem)

func onEntrySelected(theItem):
	selectedItem = theItem
	updateSelectedInfo()
	updateSelectedHighlight()
	onItemSelected.emit(selectedItem)


func _on_SearchLineEdit_text_changed(_new_text):
	filterInventory()
