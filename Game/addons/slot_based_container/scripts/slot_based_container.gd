@tool
extends  Node


const class_slot = preload("./slot.gd")
const class_item = preload("./item.gd")

signal updated()

@export var slot_dimension : Vector2i = Vector2i(5, 1):
	get:
		return slot_dimension
	set(value):
		slot_dimension = value
		_recreate()
var slots : Array[class_slot]:
	get:
		return slots


func _ready():
	_recreate()


func _recreate():
	slots.resize(slot_dimension.x * slot_dimension.y)
	for i in slots.size():
		slots[i] = class_slot.new()
	updated.emit()


func try_add_item(item : class_item, count : int = 1) -> bool:
	if item.is_stackable:
		for slot in slots:
			if slot.can_put_item(item):
				var remains : int = slot.add_item_with_remains(item, count)
				if remains > 0:
					return try_add_item(item, remains)
				return true
	for slot in slots:
		if slot.is_empty():
			var remains : int = slot.add_item_with_remains(item, count)
			if  remains > 0:
				return try_add_item(item, remains)
			return true
	return false
