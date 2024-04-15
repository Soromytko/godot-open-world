@tool
extends StaticBody3D


@export var heightmap_image : Image:
	get:
		return heightmap_image
	set(value):
		heightmap_image = value
		if is_node_ready():
			update_completely()

var _collision_shape : CollisionShape3D


func _ready():
	if _collision_shape == null:
		for child in get_children():
			if child is CollisionShape3D:
				_collision_shape = child
				break
	if _collision_shape == null:
		_collision_shape = CollisionShape3D.new()
		var shape : HeightMapShape3D = HeightMapShape3D.new()
		_collision_shape.shape = shape
		add_child(_collision_shape)
		_collision_shape.owner = owner


func update_completely():
	var shape : HeightMapShape3D = _collision_shape.shape
	if heightmap_image == null:
		return
	if heightmap_image.get_format() == Image.FORMAT_RF:
		var heights : PackedFloat32Array = heightmap_image.get_data().to_float32_array()
		_collision_shape
		shape.map_width = heightmap_image.get_width()
		shape.map_depth = heightmap_image.get_height()
		shape.map_data = heights
	else:
		print("The %s image format is not supported" % heightmap_image.get_format())


func update_region(start : Vector2i, end : Vector2i, data : PackedFloat32Array):
	var shape : HeightMapShape3D = _collision_shape.shape
	var shape_size : Vector2i = Vector2i(shape.map_width, shape.map_depth)
	start = _clamp_vector2i(start, Vector2i.ZERO, shape_size)
	end = _clamp_vector2i(end, Vector2i.ZERO, shape_size)
	var map_data : PackedFloat32Array = shape.map_data
	for i in range(start.x, end.x, 1):
		for j in range(start.x, end.x, 1):
			map_data[i * shape_size.x + j] += 1
			#shape.map_data[i * shape_size.x + j] += 1
	shape.map_data = map_data


func _clamp_vector2i(value : Vector2i, min : Vector2i, max : Vector2i) -> Vector2i:
	value.x = clampf(value.x, 0, value.x)
	value.y = clampf(value.y, 0, value.y)
	return value;
