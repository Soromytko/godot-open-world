@tool
extends Node3D

const class_plant = preload("./plant.gd")
const class_octree_node = preload("./octree_node.gd")
const class_placeform = preload("./placeform.gd")

@export var plant : Resource:
	get:
		return _plant
	set(value):
		assert(value is class_plant)
		_plant = value
		if is_node_ready():
			_init_root_node()
			_init_timer()

var _plant : class_plant
var _root_node : class_octree_node
var _timer : Timer


func _ready():
	#owner = get_tree().get_edited_scene_root()
	_init_root_node()
	_init_timer()


func insert(node_transform : Transform3D) -> class_placeform:
	var placeform := class_placeform.new()
	placeform.transform = node_transform
	return placeform if try_insert_placeform(placeform) else null 


func try_insert_placeform(placeform : class_placeform) -> bool:
	return _root_node.try_insert(placeform)


func update_lods():
	#print(name, " ", count_instances())
	_update_lod_recursively(_root_node, _get_camera().global_position)


func count_nodes() -> int:
	return _count_nodes_recursively(_root_node)


func count_instances() -> int:
	return _count_instances_recursivelty(_root_node)


func _update_lod_recursively(octree_node : class_octree_node, observer_position : Vector3):
	if octree_node.update_lod(observer_position):
		for octant in octree_node.octants:
			_update_lod_recursively(octant, observer_position)


func _count_nodes_recursively(octree_node : class_octree_node) -> int:
	var result : int = octree_node.octants.size()
	for octant in octree_node.octants:
		result += _count_nodes_recursively(octant)
	return result


func _count_instances_recursivelty(octree_node : class_octree_node) -> int:
	var result : int = octree_node.get_instance_count()
	for octant in octree_node.octants:
		result += _count_instances_recursivelty(octant)
	return result


func _init_root_node():
	if plant == null:
		return
	var maybe_root_node = find_child("OctreeRootNode", false)
	if maybe_root_node != null && maybe_root_node is class_octree_node:
		_root_node = maybe_root_node
	else:
		_root_node = class_octree_node.new()
		_root_node.depth = 0
		_root_node.size = _plant.octree_size
		_root_node.plant = _plant
		_root_node.name = "OctreeRootNode"
		add_child(_root_node)
		_root_node.owner = get_tree().get_edited_scene_root()


func _init_timer():
	if plant == null:
		return
	var timer_name := "LodUpdateRate_Timer"
	var maybe_timer = find_child(timer_name, false)
	_timer = maybe_timer if maybe_timer != null && maybe_timer is Timer else null
	if _timer == null:
		_timer = Timer.new()
		_timer.name = timer_name
		add_child(_timer)
		_timer.owner = owner
	_timer.timeout.connect(update_lods)
	#Start the timer at different points in time to distribute the load
	var delayed_start_time : float = RandomNumberGenerator.new().randf_range(0, 2)
	await get_tree().create_timer(delayed_start_time).timeout
	_timer.start(_plant.lod_update_rate)


func _get_camera() -> Camera3D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_viewport_3d().get_camera_3d()
	if get_viewport() == null:
		return null
	return get_viewport().get_camera_3d() 

