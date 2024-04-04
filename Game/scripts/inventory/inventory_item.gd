class_name InventoryItem extends "res://addons/slot_based_container/scripts/item.gd"


enum Type {
	NONE = -1,
	WOOD,
	STONE,
}


@export var type : Type = Type.NONE:
	get:
		return type
	set(value):
		type = value
		id = int(type)
