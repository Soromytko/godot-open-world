@tool
extends Node3D


const class_terrain_renderer = preload("./terrain_renderer.gd")
const class_terrain_resource_manager = preload("./terrain_resource_manager.gd")
const class_terrain_collision_shape = preload("./terrain_collision_shape.gd")

enum Resolution {
	_64 = 6,
	_128,
	_256,
	_512,
	_1024,
	_2048,
	_4096,
	_8192,
}

## The resolution of the terrain
@export var resolution : Resolution = Resolution._128:
	get:
		return _resolution
	set(value):
		_resolution = value
		if is_node_ready():
			var image_size : Vector2i = _resolution_to_image_size(resolution)
			_terrain_resource_manager.resize_heightmap(image_size)
			#TODO: This is a very bad design 
			_save_terrain_data()
			_update_completely()

@export_dir var resource_directory:
	get:
		return resource_directory
	set(value):
		resource_directory = value
		if is_node_ready():
			_update_completely()

@export_group("Debug")
@export var is_debug : bool = false:
	get:
		return is_debug
	set(value):
		is_debug = value
		if is_node_ready():
			_terrain_renderer.observer = _get_observer()

@export var observer : Node3D:
	get:
		return observer
	set(value):
		observer = value
		if is_node_ready():
			_terrain_renderer.observer = _get_observer()

var renderer : class_terrain_renderer:
	get:
		return _terrain_renderer

var collision_shape : class_terrain_collision_shape:
	get:
		return _terrain_collision_shape

var _resolution : Resolution = Resolution._128
var _terrain_renderer : class_terrain_renderer
var _terrain_resource_manager : class_terrain_resource_manager
var _terrain_collision_shape : class_terrain_collision_shape


func _ready():
	#owner = get_tree().get_edited_scene_root()
	_update_completely()


func _process(delta):
	if _terrain_renderer != null:
		_terrain_renderer.update()


func _resolution_to_image_size(resolution : Resolution) -> Vector2i:
	return Vector2i.ONE * pow(2, resolution);


func _update_completely():
	_init_resource_manager()
	_load_terrain_data()
	_init_terrain_renderer()
	_init_collision_shape()


func _init_resource_manager():
	_terrain_resource_manager = class_terrain_resource_manager.new()
	_terrain_resource_manager.path = resource_directory


func _init_terrain_renderer():
	if _terrain_renderer == null:
		for child in get_children():
			if child is class_terrain_renderer:
				_terrain_renderer = child
				break
	if _terrain_renderer == null:
		_terrain_renderer = class_terrain_renderer.new()
		add_child(_terrain_renderer)
	_terrain_renderer.heightmap_image = _terrain_resource_manager.data.heightmap_image
	_terrain_renderer.main_texture = _terrain_resource_manager.data.main_texture
	_terrain_renderer.heightmap_uv_offset = _terrain_resource_manager.data.uv_offset
	_terrain_renderer.observer = _get_observer()


func _init_collision_shape():
	if _terrain_collision_shape == null:
		for child in get_children():
			if child is class_terrain_collision_shape:
				_terrain_collision_shape = child
				break
	if _terrain_collision_shape == null:
		_terrain_collision_shape = class_terrain_collision_shape.new()
		add_child(_terrain_collision_shape)
		#_terrain_collision_shape.owner = owner
	if _terrain_resource_manager.data != null && _terrain_resource_manager.data.heightmap_image != null:
		_terrain_collision_shape.heightmap_image = _terrain_resource_manager.data.heightmap_image


func _load_terrain_data():
	if not _terrain_resource_manager.try_load_terrain_data():
		_terrain_resource_manager.try_create_terrain_data(Vector2i.ONE * _resolution)
	else:
		var heightmap_size : Vector2i = _terrain_resource_manager.data.heightmap_image.get_size()
		var max_value : float = heightmap_size[heightmap_size.max_axis_index()]
		_resolution = int(log(max_value) / log(2))


func _save_terrain_data():
	_terrain_resource_manager.try_save_terrain_data()


func _get_observer() -> Node3D:
	if is_debug:
		return observer if observer != null else _get_camera()
	return _get_camera()


func _get_camera() -> Camera3D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_viewport_3d().get_camera_3d()
	if get_viewport() == null:
		return null
	return get_viewport().get_camera_3d()
