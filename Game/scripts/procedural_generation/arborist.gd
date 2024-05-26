@tool
extends Node3D

const class_octree = preload("res://addons/spatial_nature/scripts/octree.gd")
const class_placeform = preload("res://addons/spatial_nature/scripts/placeform.gd")

@export var size : Vector3 = Vector3.ONE
@export var heightmap : Image
@export var plants : Array[Plant]
@export_group("Debug")
@export var clear : bool:
	set(value):
		if is_node_ready():
			_clear()
@export var generate : bool:
	set(value):
		if is_node_ready():
			_clear()
			_generate_with_noise()
			_update_all_trees_lods()
@export var insert_random : bool:
	set(value):
		if is_node_ready():
			var plant_transform := Transform3D()
			var rng := RandomNumberGenerator.new()
			plant_transform.origin = Vector3(
				rng.randf_range(-10, 10),
				rng.randf_range(-10, 10),
				rng.randf_range(-10, 10)
			)
			_octrees[0].insert(plant_transform)

var _octrees : Array[class_octree]


func _ready():
	_init_octrees()
	_generate_with_noise()
	_update_all_trees_lods()


func _init_octrees():
	for child in get_children():
		child.queue_free()
		remove_child(child)
	_octrees.resize(plants.size())
	for i in _octrees.size():
		var octree := class_octree.new()
		add_child(octree)
		#octree.owner = owner
		octree.name = "%s_Octree" % plants[i].resource_name
		_octrees[i] = octree
		octree.plant = plants[i]


func _clear():
	_init_octrees()


@export var pine_count : int
@export var grass_count : int
@export var bush_count : int

func _update_all_trees_lods():
	for tree in _octrees:
		tree.update_lods()


func _on_update_lods(octree : class_octree):
	print("AAAAAAAAAA")
	if octree.name.contains("Pine"):
		print(octree.name, " ", octree.count_instances())
	elif octree.name.contains("Bush"):
		print(octree.name, " ", octree.count_instances())
	elif octree.name.contains("Grass"):
		print(octree.name, " ", octree.count_instances())
	octree.update_lods()


func _generate_with_noise():
	var rng := RandomNumberGenerator.new()
	rng.seed = Time.get_ticks_msec()
	for octree in _octrees:
		var plant : Plant = octree.plant
		var heightmap := heightmap
		var noise_map := plant.noise_map
		for i in noise_map.get_width():
			for j in noise_map.get_height():
				for f in plant.frequency_degree:
					var noise_value := noise_map.get_pixel(i, j).r
					if noise_value < plant.min_noise_value:
						continue
					if rng.randf_range(0, 1) > plant.frequency:
						continue
					var plant_transform := Transform3D()
					plant_transform = plant_transform.rotated(Vector3.UP, rng.randf_range(0.0, 2.0 * PI))
					plant_transform = plant_transform.scaled(Vector3.ONE * rng.randf_range(plant.min_size, plant.max_size))
					plant_transform.origin = Vector3(
						i,
						heightmap.get_pixel(i, j).r,
						j
					) + _get_random_deviation_vector(rng, 4.0)
					plant_transform.origin -= Vector3(noise_map.get_width(), 0, noise_map.get_height()) / 2
					plant_transform.origin = plant_transform.origin / \
						Vector3(noise_map.get_width(), 1, noise_map.get_height()) * \
						size
					plant_transform.origin = _get_point_on_heightmap(plant_transform.origin)
					octree.insert(plant_transform)


func _get_random_deviation(rng : RandomNumberGenerator, deviation : float) -> float:
	return rng.randf_range(-deviation, deviation)


func _get_random_deviation_vector(rng : RandomNumberGenerator, deviation : float = 1.0) -> Vector3:
	return Vector3(
		rng.randf_range(-deviation, deviation),
		rng.randf_range(-deviation, deviation),
		rng.randf_range(-deviation, deviation)
	)


func _get_point_on_heightmap(point : Vector3) -> Vector3:
	var uv : Vector2i = Vector2i(point.x, point.z) + heightmap.get_size() / 2
	uv.x = clampi(uv.x, 0, heightmap.get_width() - 1)
	uv.y = clampi(uv.y, 0, heightmap.get_height() - 1)
	var h := heightmap.get_pixelv(uv).r
	return Vector3(point.x, h, point.z)

