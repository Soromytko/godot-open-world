extends Node3D


const class_slot_based_container = preload("res://addons/slot_based_container/scripts/slot_based_container.gd")
const class_item = preload("res://addons/slot_based_container/scripts/item.gd")
const class_picker = preload("./picker.gd")

@onready var slot_based_container : class_slot_based_container = $SlotBasedContainer
@onready var _picker : class_picker = $Picker


func _ready():
	_picker.pickup_item_entered.connect(_on_pickup_item_entered)


func try_add_item(item : InventoryItem, count : int = 1) -> bool:
	return slot_based_container.try_add_item(item, count)


func _on_pickup_item_entered(pickup_item : class_picker.class_pickup_item):
	var item : class_item = pickup_item.item
	if slot_based_container.try_add_item(pickup_item.item):
		pickup_item.queue_free()

