@tool
extends Node

@export var generate: bool: set = _generate
@export var grain_size : int = 5
@export var angularity : int = 5


var mesh_instance : MeshInstance3D
var texture_rect : TextureRect


func _get_components():
	mesh_instance = $MeshInstance3D
	texture_rect = $Control/TextureRect
	

func _create_heights(x, y, default_value : float):
	var heights = []
	heights.resize(x)
	for i in heights.size():
		heights[i] = []
		heights[i].resize(y)
		for j in heights[i].size():
			heights[i][j] = default_value
	return heights
			

func _generate(__):
	var size = 100
	_get_components()
	

		
#	var rng = RandomNumberGenerator.new()
#	rng.seed = hash(OS.get_time())
#	for i in heights.size():
#		for j in heights[i].size():
#			heights[i][j] = rng.randf_range(0, 1)
#			print(heights[i][j])
	
	var heights = _create_heights(size, size, 1)

	var rng = RandomNumberGenerator.new()
	rng.seed = hash(OS.get_time())
	for i in grain_size:
		heights[rng.randi_range(0, size - 1)][rng.randi_range(0, size - 1)] = 0
			

	
		
	texture_rect.update_with_heights(heights)
	
