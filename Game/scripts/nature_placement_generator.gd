@tool
extends Node


const class_arborist = preload("res://addons/dreadpon.spatial_gardener/arborist/arborist.gd")
const class_greenhouse_plant_state = preload("res://addons/dreadpon.spatial_gardener/greenhouse/greenhouse_plant_state.gd")
const class_greenhouse_plant = preload("res://addons/dreadpon.spatial_gardener/greenhouse/greenhouse_plant.gd")
const class_greenhouse_lod_variant = preload("res://addons/dreadpon.spatial_gardener/greenhouse/greenhouse_LOD_variant.gd")
const class_placeform = preload("res://addons/dreadpon.spatial_gardener/arborist/placeform.gd")
const class_transform_generator = preload("res://addons/dreadpon.spatial_gardener/arborist/transform_generator.gd")


@export var heightmap_image : Image:
	get:
		return heightmap_image
	set(value):
		heightmap_image = value

@export var tree_array_mesh : ArrayMesh

@export var generate : bool:
	set(value):
		_init_arborist()
		return
		_clear()
		_generate()


@export var lod_variants : Array[Resource]:
	get:
		return lod_variants
	set(value):
		lod_variants = value

var _arborist : class_arborist


func _ready():
	_init_arborist()


func _get_node_by_type(type : Variant) -> Variant:
	for child in get_children():
		if is_instance_of(child, type):
			return child
	return null


func _init_arborist():
	_arborist = _get_node_by_type(class_arborist)
	if _arborist == null:
		_arborist = class_arborist.new()
		add_child(_arborist)
	_arborist.owner = owner
	_arborist.name = "Arborist"
	_arborist.reset_octree_managers()
	var plant_state := class_greenhouse_plant_state.new()
	var plant := class_greenhouse_plant.new()
	plant.set_mesh_lod_variants(lod_variants)
	_arborist.add_plant_octree_manager(plant_state.plant, 0)
	var placeforms := _generate_plant_placeforms(plant)
	_arborist.add_placeforms(placeforms, 0)



func _generate_plant_placeforms(plant : class_greenhouse_plant) -> Array:
	var randomizer := RandomNumberGenerator.new()
	var position := Vector3.ZERO
	var normal := Vector3.UP
	var plant_transform := class_transform_generator.generate_plant_transform(position, normal, plant, randomizer)
	var placeform := class_placeform.mk(position, normal, plant_transform)
	return [placeform]


func _generate():
	return
	var rng := RandomNumberGenerator.new()
	var random_point : Vector2i
	var h : float
	for i in 1000:
		random_point.x = rng.randi_range(0, heightmap_image.get_width() - 1)
		random_point.y = rng.randi_range(0, heightmap_image.get_height() - 1)
		h = heightmap_image.get_pixelv(random_point).r
		var tree = MeshInstance3D.new()
		tree.mesh = tree_array_mesh
		add_child(tree)
		tree.global_position = Vector3(
			random_point.x - heightmap_image.get_width() / 2,
			h,
			random_point.y - heightmap_image.get_height() / 2)


func _clear():
	for child in get_children():
		child.queue_free()
