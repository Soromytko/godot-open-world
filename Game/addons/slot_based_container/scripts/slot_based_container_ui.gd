@tool
extends Control


const class_slot_based_container = preload("./slot_based_container.gd")
const class_slot = preload("./slot.gd")
const class_slot_ui = preload("./slot_ui.gd")

@export var slot_based_container : class_slot_based_container:
	get:
		return slot_based_container
	set(value):
		slot_based_container = value
		slot_based_container.updated.connect(_update_completely)
		_update_completely()

@export var slot_ui_scene : PackedScene = preload("../scenes/slot.tscn"):
	get:
		return slot_ui_scene
	set(value):
		slot_ui_scene = value
		_update_completely()

var _grid_container : GridContainer


func _update_completely():
	if _grid_container != null:
		_grid_container.queue_free()
	if slot_based_container == null || \
		slot_ui_scene == null || \
		slot_based_container.slot_dimension.x <= 0 || \
		slot_based_container.slot_dimension.y <= 0:
		return
	_grid_container = GridContainer.new()
	_grid_container.columns = slot_based_container.slot_dimension.x
	add_child(_grid_container)
	
	for i in slot_based_container.slots.size():
		var slot : class_slot = slot_based_container.slots[i]
		var slot_ui : class_slot_ui = slot_ui_scene.instantiate()
		slot_ui.connect_slot(slot)
		_grid_container.add_child(slot_ui)
	#This is a workaround, because for some reason
	#the size of _grid_container is not updated instantly
	size = _calculate_gird_container_size(_grid_container)


func _calculate_gird_container_size(grid_container : GridContainer) -> Vector2:
	var result : Vector2
	var children = grid_container.get_children()
	if children.size() == 0:
		return result
	var h_spacing : float = grid_container.get_theme_constant("hseparation")
	var v_spacing : float = grid_container.get_theme_constant("vseparation")
	# default value
	h_spacing = 4
	v_spacing = 4
	for i in grid_container.columns:
		if i > children.size():
			break
		result.x += children[i].size.x + h_spacing
	result.y = (children[0].size.y + v_spacing) * \
		children.size() / float(grid_container.columns)
	return result
