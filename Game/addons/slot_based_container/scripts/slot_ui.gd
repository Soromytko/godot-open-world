@tool
extends TextureRect


const class_slot_based_container_slot = preload("./slot.gd")

@onready var _item_icon_rect_texture : TextureRect = $ItemIcon
@onready var _item_count_label : Label = $ItemCount
var _connected_slot : class_slot_based_container_slot


func _ready():
	_item_icon_rect_texture.visible = false
	_item_count_label.visible = false


func connect_slot(slot : class_slot_based_container_slot):
	_connected_slot = slot
	_connected_slot.updated.connect(on_slot_updated)


func on_slot_updated():
	_item_icon_rect_texture.visible = !_connected_slot.is_empty()
	_item_icon_rect_texture.texture = _connected_slot.item.icon
	
	_item_count_label.visible = !_connected_slot.is_empty()
	_item_count_label.text = str(_connected_slot.item_count)

