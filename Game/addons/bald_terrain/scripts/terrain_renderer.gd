@tool
extends Node3D


const class_terrain_chunk = preload("./terrain_chunk.gd")
const class_terrain_mesh_supplier = preload("./terrain_mesh_supplier.gd")
const shader = preload("../shaders/terrain.gdshader")

var heightmap_image : Image:
	get:
		return heightmap_image
	set(value):
		heightmap_image = value
		if heightmap_image != null:
			_heightmap_texture = ImageTexture.create_from_image(heightmap_image)
		if is_node_ready():
			_node_config.size = _calculate_chunk_size()
			_node_config.max_distance = _calculate_chunk_max_distance()
			_tree_config.max_quadtree_depth = _calculate_quadtree_max_depth()
			_tree_config.heightmap_texture = _heightmap_texture
			_create_terrain()

var heightmap_uv_offset : Vector2:
	get:
		return heightmap_uv_offset
	set(value):
		heightmap_uv_offset = value
		if is_node_ready():
			_tree_config.heightmap_uv_offset = heightmap_uv_offset

var main_texture : Texture:
	get:
		return main_texture
	set(value):
		main_texture = value
		if is_node_ready():
			_tree_config.main_texture = main_texture

var observer : Node3D:
	get:
		return observer
	set(value):
		observer = value
		if is_node_ready():
			_tree_config.observer = observer

const _mesh_subdivision : int = 7
var _mesh_supplier : class_terrain_mesh_supplier
var _root_chunk : class_terrain_chunk
var _node_config : class_terrain_chunk.NodeConfig
var _tree_config : class_terrain_chunk.TreeConfig
var _heightmap_texture : ImageTexture


func update_heightmap_texture():
	if heightmap_image == null || _heightmap_texture == null:
		return
	_heightmap_texture.update(heightmap_image)


func update():
	if _root_chunk != null:
		#print(_root_chunk.tree_config.observer)
		_root_chunk.update_recursively()

func _ready():
	#owner = get_tree().get_edited_scene_root()
	_prepare_mesh()
	_create_node_config()
	_create_tree_config()
	_create_terrain()


func _prepare_mesh():
	_mesh_supplier = class_terrain_mesh_supplier.new()
	_mesh_supplier.create_meshes(_mesh_subdivision * 2 + 1)


func _calculate_quadtree_max_depth() -> int:
	if heightmap_image == null:
		return 0
	var heightmap_size : Vector2 = heightmap_image.get_size()
	var axis_value : float = heightmap_size[heightmap_size.min_axis_index()]
	#log(axes_value, 2)
	return log(axis_value) / log(2) - 4


func _calculate_chunk_size() -> Vector3:
	if heightmap_image == null:
		return Vector3.ZERO
	var size : Vector2 = heightmap_image.get_size() - Vector2i.ONE 
	return Vector3(size.x, size[size.max_axis_index()], size.y)


func _calculate_chunk_max_distance() -> float:
	if heightmap_image == null:
		return 0
	var size : Vector2 = heightmap_image.get_size() - Vector2i.ONE  
	return size[size.max_axis_index()] * 4


func _create_tree_config():
	var tree_config : class_terrain_chunk.TreeConfig = class_terrain_chunk.TreeConfig.new()
	tree_config.main_texture = main_texture
	tree_config.heightmap_texture = _heightmap_texture
	tree_config.max_quadtree_depth = _calculate_quadtree_max_depth()
	#tree_config.update_timeout = update_timeout
	tree_config.observer = observer
	tree_config.shader = shader
	tree_config.meshes = _mesh_supplier.meshes
	_tree_config = tree_config


func _create_node_config():
	var node_config : class_terrain_chunk.NodeConfig = class_terrain_chunk.NodeConfig.new()
	node_config.parent = null
	node_config.depth = 0
	node_config.max_distance = _calculate_chunk_max_distance()
	node_config.size = _calculate_chunk_size()
	_node_config = node_config


func _create_terrain():
	if _root_chunk == null:
		for child in get_children():
			if child is class_terrain_chunk:
				_root_chunk = child
				break
	if _root_chunk != null:
		_root_chunk.queue_free()
	_root_chunk = class_terrain_chunk.new(_node_config, _tree_config)
	add_child(_root_chunk)
	#_quadtree.owner = owner
	_tree_config.root = _root_chunk

