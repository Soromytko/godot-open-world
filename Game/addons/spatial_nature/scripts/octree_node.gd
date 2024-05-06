@tool
extends Node3D

# A hack to get a type of self
const class_self = preload("./octree_node.gd")
const class_plant = preload("./plant.gd")
const class_lod_variant = preload("./lod_variant.gd")
const class_placeform = preload("./placeform.gd")
const class_destroyable = preload("./destroyable.gd")

@export var plant : Resource:
	get:
		return _plant
	set(value):
		if value != null:
			assert(value is class_plant)
		_plant = value
		_construct_lod_bounds()
@export var depth : int:
	get:
		return depth
@export var bounds : AABB:
	get:
		return bounds
var placeforms : Array[class_placeform]:
	get:
		return placeforms 
var is_leaf : bool:
	get:
		return octants.size() == 0
var octants : Array[class_self]:
	get:
		return octants
var _plant : class_plant:
	get:
		return _plant
#var _multi_mesh_instance_owner : Node
var _lod_bounds : Array[AABB]
var _multi_mesh_instance : MultiMeshInstance3D
var _destroyable_scene : PackedScene
var _debug_mesh_instance : MeshInstance3D


#func _ready():
	#if _init_multi_mesh_instance():
		#_init_placeforms_by_multi_mesh_instance()
	#_init_octants()


func _enter_tree():
	#_init_octants()
	#_create_multi_mesh_instance()
	#_connect_signals()
	#_create_debug_box()
	pass


#func _exit_tree():
	#_disconnect_signals()


func update_lod(observer_position : Vector3):
	#TODO: The nodes of the octree that are not leaves
	#can contain values only if the values are not points.
	if _multi_mesh_instance == null || _plant.lod_variants.size() == 0:
		return
	var relative_observer_position := _get_relative_position(observer_position)
	#TODO: Start from the last LOD to reduce the number of cycles
	for i in _lod_bounds.size():
		if _lod_bounds[i].has_point(relative_observer_position):
			#_multi_mesh_instance.visible = true
			_set_current_lod(i)
			_multi_mesh_instance.visible = true
			return
	#_set_current_lod(_plant.lod_variants.size() - 1)
	if _plant.is_killable_by_distance:
		_multi_mesh_instance.visible = false
		_clear_destroyables()


func get_instance_count() -> int:
	if _multi_mesh_instance == null || _multi_mesh_instance.multimesh == null:
		return 0
	return _multi_mesh_instance.multimesh.instance_count


#func _init_multi_mesh_instance() -> bool:
	#for child in get_children():
		#if child is MultiMeshInstance3D:
			#_multi_mesh_instance = child
			#return true
	#return false


#func _init_placeforms_by_multi_mesh_instance() -> bool:
	#if _multi_mesh_instance == null || _multi_mesh_instance.multimesh == null:
		#return false
	#var multi_mesh := _multi_mesh_instance.multimesh
	#placeforms.resize(multi_mesh.instance_count)
	#for i in placeforms.size():
		#var placeform := class_placeform.new()
		#placeform.transform = multi_mesh.get_instance_transform(i)
		#placeforms[i] = placeform
	#return true


#func _init_octants():
	#octants.clear()
	#for child in get_children():
		#if octants.size() == 8:
			#break
		#if child is class_self:
			#octants.append(child)


func _on_max_lod_distance_changed(value : float):
	_construct_lod_bounds()


func _construct_lod_bounds():
	if plant == null:
		return
	_lod_bounds.resize(_plant.lod_variants.size())
	var octant_size := bounds.size
	for i in _lod_bounds.size():
		#var size := octant_size + octant_size * (i + 1) * _plant.max_lod_distance
		var lod_variant : class_lod_variant = _plant.lod_variants[i]
		var size := octant_size * lod_variant.lod_distance
		_lod_bounds[i] = _create_centered_bounds(size)


func _set_current_lod(lod_index : int):
	var lod_variant : class_lod_variant = _plant.lod_variants[lod_index]
	if _multi_mesh_instance.multimesh.mesh == lod_variant.mesh:
			return
	_multi_mesh_instance.multimesh.mesh = lod_variant.mesh
	_multi_mesh_instance.cast_shadow = lod_variant.shadow_casting
	_update_destroyables(lod_variant.destroyable_scene)


func _update_destroyables(destroyable_scene : PackedScene):
	if _destroyable_scene == destroyable_scene:
		return
	_clear_destroyables()
	_destroyable_scene = destroyable_scene
	if _destroyable_scene != null:
		_create_destroyables(destroyable_scene)


func _create_destroyables(destroyable_scene : PackedScene):
	var multi_mesh := _multi_mesh_instance.multimesh
	for i in multi_mesh.instance_count:
		var destroyable : class_destroyable = destroyable_scene.instantiate()
		destroyable.name = "spawned_%d" % i
		_multi_mesh_instance.add_child(destroyable)
		destroyable.owner = owner
		destroyable.transform = multi_mesh.get_instance_transform(i)
		placeforms[i].destroyable = destroyable


func _clear_destroyables():
	for placeform in placeforms:
		placeform.destroyable = null


func _on_placeform_destroyed(placeform_index : int):
	placeforms.remove_at(placeform_index)
	_update_placeform_indexes(placeform_index)
	_refresh_multi_mesh_instance()


func _update_placeform_indexes(start_with : int = 0):
	for i in range(start_with, placeforms.size(), 1):
		placeforms[i].index = i


func _set_last_lod():
	if _plant.lod_variants == null || _plant.lod_variants.size() == 0:
		return
	_set_current_lod(_plant.lod_variants.size() - 1)


func _create_centered_bounds(size : Vector3) -> AABB:
	return AABB(-size / 2, size)


func try_insert(placeform : class_placeform) -> bool:
	if not _intersects(placeform):
		return false
	if is_leaf:
		if _try_append_placeform(placeform):
			return true
		elif not _try_subdivide():
			return false
	return _try_insert_into_children(placeform)


func _try_insert_into_children(placeform : class_placeform) -> bool:
	for octant in octants:
		if octant.try_insert(placeform):
			return true
	return false


func _can_subdivide() -> bool:
	return depth < _plant.max_depth


func _try_subdivide() -> bool:
	if not _can_subdivide():
		return false
	var octant_bounds := _create_octant_bounds()
	for octant_index in 8:
		var octant := class_self.new()
		octant.depth = depth + 1
		octant.bounds = octant_bounds
		octant.plant = plant
		octant.name = "OctreeNode%d" % octant_index
		add_child(octant)
		octant.owner = owner
		octant.position = _get_octant_position(octant_index)
		octants.append(octant)
	var remaining_placeforms : Array[class_placeform]
	for placeform in placeforms:
		if _try_insert_into_children(placeform):
			_disconnect_placeform(placeform)
		else:
			remaining_placeforms.append(placeform)
	if placeforms.size() != remaining_placeforms.size():
		placeforms = remaining_placeforms
		_update_placeform_indexes()
		_refresh_multi_mesh_instance()
	return true


func _create_octant_bounds() -> AABB:
	var half_bounds_size := bounds.size / 2
	return AABB(-half_bounds_size / 2, half_bounds_size)


func _get_relative_position(node_position : Vector3) -> Vector3:
	return node_position - global_position


func _intersects(placeform : class_placeform) -> bool:
	var relative_position := _get_relative_position(placeform.transform.origin)
	return bounds.has_point(relative_position)
	#TODO: Check bounds
	#return bounds.intersects(value.bounds)


func _get_octant_position(octant_index : int) -> Vector3:
	var quarter_size : Vector3 = bounds.size * 0.25
	match octant_index:
		0: return Vector3(-1, -1, -1) * quarter_size 
		1: return Vector3(-1, -1, +1) * quarter_size
		2: return Vector3(-1, +1, -1) * quarter_size
		3: return Vector3(-1, +1, +1) * quarter_size
		4: return Vector3(+1, -1, -1) * quarter_size
		5: return Vector3(+1, -1, +1) * quarter_size
		6: return Vector3(+1, +1, -1) * quarter_size
		7: return Vector3(+1, +1, +1) * quarter_size
	print("Incorrect octant index (%d). The index must match the inequality: 0 <= octant_index <= 7" % octant_index)
	return Vector3.ZERO


func _try_append_placeform(placeform : class_placeform) -> bool:
	if placeforms.size() < _plant.node_capacity:
		_connect_placeform(placeform)
		placeform.index = placeforms.size()
		placeforms.append(placeform)
		_refresh_multi_mesh_instance()
		#_add_instance(placeform)
		return true
	return false


func _connect_placeform(placeform : class_placeform):
	placeform.destroyed.connect(_on_placeform_destroyed)


func _disconnect_placeform(placeform : class_placeform):
	placeform.destroyed.disconnect(_on_placeform_destroyed)


func _remove_placeform(placeform : class_placeform):
	var placeform_index := placeforms.bsearch(placeform)
	_remove_placeform_by_index(placeform_index)


func _remove_placeform_by_index(placeform_index : int):
	var placeform := placeforms[placeform_index]
	placeform.destroyed.disconnect(_on_placeform_destroyed)
	placeforms.remove_at(placeform_index)


func _refresh_multi_mesh_instance():
	if placeforms.size() == 0:
		_destroy_multi_mesh_instance()
		return
	if _multi_mesh_instance == null:
		_create_multi_mesh_instance()
	var multi_mesh := _multi_mesh_instance.multimesh
	# Assigning the instance_count throws an error if the mesh is null
	if multi_mesh.mesh == null:
		return
	multi_mesh.instance_count = placeforms.size()
	for i in placeforms.size():
		var placeform := placeforms[i]
		var placeform_transform := placeform.transform
		placeform_transform.origin -= _multi_mesh_instance.global_position
		multi_mesh.set_instance_transform(i, placeform_transform)


func _create_multi_mesh_instance():
	_multi_mesh_instance = MultiMeshInstance3D.new()
	add_child(_multi_mesh_instance)
	_multi_mesh_instance.owner = get_tree().get_edited_scene_root()
	_multi_mesh_instance.name = "MultiMeshInstance3D"
	var multi_mesh := MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	_multi_mesh_instance.multimesh = multi_mesh
	#update_lod(Vector3.ONE)
	_set_last_lod()


func _destroy_multi_mesh_instance():
	if _multi_mesh_instance != null:
		_multi_mesh_instance.queue_free()
		_multi_mesh_instance = null


func _create_debug_box():
	if _debug_mesh_instance == null:
		_debug_mesh_instance = MeshInstance3D.new()
		_debug_mesh_instance.mesh = BoxMesh.new()
		add_child(_debug_mesh_instance)
		#_debug_mesh_instance.owner = get_tree().get_edited_scene_root()
		_debug_mesh_instance.name = "DebugBoxMeshInstance"
	_debug_mesh_instance.position = Vector3.ZERO
	_debug_mesh_instance.scale = bounds.size
	var material : StandardMaterial3D = StandardMaterial3D.new()
	var r : float = depth / float(_plant.max_depth)
	material.albedo_color = Color(r, 0, 0, 1)
	_debug_mesh_instance.material_override = material
