@tool
class_name TerrainQuadtreeNode
extends Node3D


class Quarter:
	const FIRST : Vector3 = Vector3(-1, 0, -1)
	const SECOND : Vector3 = Vector3(1, 0, -1)
	const THIRD : Vector3 = Vector3(-1, 0, 1)
	const FOURTH : Vector3 = Vector3(1, 0, 1)



signal loaded()
signal updated()
signal released()
signal mesh_created()
signal mesh_released()


class NodeConfig:
	var parent : TerrainQuadtreeNode
	var depth : int
	var max_distance : float
	var size : Vector3


class TreeConfig:
	var root : TerrainQuadtreeNode
	var observer : Node3D
	var max_quadtree_depth : int
	var meshes = [[[[]]]]
	var heightmap_texture : ImageTexture
	var main_texture : Texture
	var shader : Shader
	var heightmap_uv_offset : Vector2


var node_config : NodeConfig:
	get:
		return node_config

var tree_config : TreeConfig:
	get:
		return tree_config

var _heightmap_offset : Vector2
var _children : Array[TerrainQuadtreeNode]
var mesh_instance : MeshInstance3D:
	get:
		return mesh_instance


func _init(node_config : NodeConfig, tree_config : TreeConfig):
	self.node_config = node_config
	self.tree_config = tree_config


func is_leaf():
	return _children.size() == 0


func get_length():
	var result : int = _children.size();
	for child in _children:
		result += child.get_length()
	return result


func update_recursively():
	#print(_can_subdivide())
	if _can_subdivide():
		if is_leaf():
			_release_mesh()
			_create_children()
			updated.emit()
		for child in _children:
			child.update_recursively()
	else:
		if !is_leaf():
			_release_children()
		_update_mesh()


func _can_subdivide() -> bool:
	return is_pretty_close_to_observer() && node_config.depth < tree_config.max_quadtree_depth


func _create_child_config() -> NodeConfig:
	var child_config = NodeConfig.new()
	child_config.parent = self
	child_config.depth = node_config.depth + 1
	child_config.max_distance = node_config.max_distance / 2
	child_config.size = node_config.size / 2
	return child_config


func _create_children():
	_children.resize(4)
	var child_config : NodeConfig = _create_child_config()
	for i in _children.size():
		_children[i] = TerrainQuadtreeNode.new(child_config, tree_config)
		add_child(_children[i])
		_children[i].owner = owner
	_children[0]._set_position_in_quadtree(Quarter.FIRST)
	_children[1]._set_position_in_quadtree(Quarter.SECOND)
	_children[2]._set_position_in_quadtree(Quarter.THIRD)
	_children[3]._set_position_in_quadtree(Quarter.FOURTH)
	for child in _children:
		child.loaded.emit()


func _set_position_in_quadtree(quarter_offset : Vector3):
	position = quarter_offset * node_config.size / 2
	var root : TerrainQuadtreeNode = tree_config.root
	var root_size : Vector3 = root.node_config.size
	var global_origin = -Vector3.ONE * 0.5 * root_size + root.global_position
	var local_origin = global_position - node_config.size / 2
	var offset = (local_origin - global_origin) / root_size
	_heightmap_offset = Vector2(offset.x, offset.z)


func _release_children():
	for child in _children:
		child._release_children()
		child.queue_free()
	_children.clear()


func _update_mesh():
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		add_child(mesh_instance)
		mesh_instance.owner = owner
		mesh_instance.ignore_occlusion_culling = true
		mesh_instance.extra_cull_margin = 100
		mesh_instance.scale = Vector3(node_config.size.x, 1, node_config.size.z)
		mesh_instance.material_override = _create_material()
		mesh_created.emit()
	mesh_instance.mesh = _get_suitable_mesh()


func _get_suitable_mesh() -> Mesh:
	var left_index : int = 0
	var right_index : int = 0
	var back_index : int = 0
	var forward_index : int = 0
	
	if node_config.parent != null:
		var parent : TerrainQuadtreeNode = node_config.parent
		var parent_config : NodeConfig = parent.node_config
		var parent_size : Vector3 = parent_config.size
		var signs : Vector3i = sign(position)
		
		var x_neighbor_offset : Vector3 = Vector3.RIGHT * signs.x * parent_size.x
		var z_neighbor_offset : Vector3 = -Vector3.FORWARD * signs.z * parent_size.z
		var x_has_neighbor : int = int(!parent.is_pretty_close_to_observer(x_neighbor_offset))
		var z_has_neighbor : int = int(!parent.is_pretty_close_to_observer(z_neighbor_offset))
		
		if signs.x < 0:
			left_index = x_has_neighbor
		else:
			right_index = x_has_neighbor
		if signs.z < 0:
			back_index = z_has_neighbor
		else:
			forward_index = z_has_neighbor
			
	return tree_config.meshes[left_index][right_index][back_index][forward_index]


func is_pretty_close_to_observer_sphere(position : Vector3, max_distance : float) -> bool:
	var distance : float = tree_config.observer.global_position.distance_to(position)
	return distance < max_distance   


func is_pretty_close_to_observer(node_offet : Vector3 = Vector3.ZERO) -> bool:
	#return tree_config.observer.global_position.distance_to(global_position + node_offet) < _config.max_distance
	var relative_observer_position : Vector3 = tree_config.observer.global_position - global_position - node_offet
	var box_size : Vector3 = node_config.size * 2
	box_size.y *= 5
	box_size.y += tree_config.root.node_config.size.y
	return relative_observer_position.x < box_size.x && relative_observer_position.x > -box_size.x && \
		relative_observer_position.y < box_size.y * 2 && relative_observer_position.y > 0 && \
		relative_observer_position.z < box_size.z && relative_observer_position.z > -box_size.z


func _create_material():
	var material : ShaderMaterial = ShaderMaterial.new()
	material.shader = tree_config.shader
	material.set_shader_parameter("main_texture", tree_config.main_texture)
	material.set_shader_parameter("heightmap", tree_config.heightmap_texture)
	#material.set_shader_parameter("height", 1.0)
	#material.set_shader_parameter("pixels_per_meter", 1.0)
	#material.set_shader_parameter("vertex_step", Vector3.ONE * 1)
	material.set_shader_parameter("heightmap_uv_offset", tree_config.heightmap_uv_offset)
	var tiling : Vector3 = tree_config.root.node_config.size / 10
	material.set_shader_parameter("main_texture_tiling", Vector2(tiling.x, tiling.z))
	return material


func _release_mesh():
	if mesh_instance != null:
		mesh_instance.queue_free()
		mesh_released.emit()
		mesh_instance = null

