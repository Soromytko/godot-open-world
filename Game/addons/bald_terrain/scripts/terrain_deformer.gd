@tool
extends Node3D


const class_terrain := preload("res://addons/bald_terrain/scripts/terrain.gd")

class Brush:
	var power : float = 1.0
	var stiffness : float = 0.5

@export var terrain : class_terrain


func _ready():
	for child in get_parent().get_children():
		if child is class_terrain:
			terrain = child
			break

func deform_by_square(start : Vector2i, end : Vector2i, brush : Brush):
	if terrain == null:
		push_warning("Terrain is null")
		return
	
	var terrain_heightmap_image = terrain.renderer.heightmap_image
	for i in range(start.x, end.x):
		for j in range(start.y, end.y):
			var color : Color = terrain_heightmap_image.get_pixel(i, j)
			color.r += brush.power
			terrain_heightmap_image.set_pixel(i, j, color)
	terrain.renderer.update_heightmap_texture()
	
	var terrain_collision_shape = terrain.collision_shape
	terrain_collision_shape.update_region(start, end, [])


func deform_by_circle(center : Vector3, radius : float, brush : Brush):
	if terrain == null:
		push_warning("Terrain is null")
		return
	
	var terrain_heightmap_image = terrain.renderer.heightmap_image
	center += Vector3.ONE * 128 / 2
	var start : Vector3i = center - Vector3.ONE * radius
	var end : Vector3i = Vector3(start) + Vector3.ONE * radius * 2
	print(start, end)
	for i in range(start.x, end.x):
		for j in range(start.z, end.z):
			var current_point : Vector3 = Vector3(i, center.y, j)
			var distance_to_center : float = current_point.distance_to(center)
			print(distance_to_center, " ", radius)
			if distance_to_center <= radius:
				var color : Color = terrain_heightmap_image.get_pixel(i, j)
				color.r += brush.power / distance_to_center
				terrain_heightmap_image.set_pixel(i, j, color)
	terrain.renderer.update_heightmap_texture()


@export var deform : bool:
	set(value):
		var brush : Brush = Brush.new()
		brush.power = -0.1
		var start = Vector2i.ONE
		var end = start + Vector2i.ONE * 10
		#deform_by_square(start, end, brush)
		deform_by_circle(global_position, 100, brush)
		print("Deform")
