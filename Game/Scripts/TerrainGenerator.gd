extends Node3D

#var _ = preload("res://Scripts/DiamondSquare.gd")

@export var generate: bool: set = generateM
@export var width : int = 16
@export var depth : int = 16
@export var smoothing : float = 1
@export var roughness : float = 0.1
@export var is_random_seed = false
@export var height = 2
@export var sea_level = 10
@export var default_seed : String = "Something"

var mesh_instance
var water_mesh_instance

var vertx = []

func generateM(value):
	mesh_instance = $MeshInstance3D
	water_mesh_instance = $MeshInstance3D/MeshInstance3D
	_generate()


func build_mesh(vertices, indices):
	var normals = []
	normals.resize(vertices.size())
	for i in normals.size():
		normals[i] = Vector3(0, 1, 0)
	
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	mesh_data[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
	mesh_data[ArrayMesh.ARRAY_INDEX] = PackedInt32Array(indices)
	mesh_data[ArrayMesh.ARRAY_NORMAL] = PackedVector3Array(normals);
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(array_mesh, 0)
	surface_tool.generate_normals()
	
	mesh_instance.mesh = surface_tool.commit()
	
	print("mesh is built")
	
	$CollisionShape3D.shape = array_mesh.create_trimesh_shape()
	


func _get_1d_from_2d(i, j, i_size, j_size):
	return -1 if i >= i_size || j >= j_size  else i * i_size + j

	

func _generate_heightmap(x_count : int, z_count : int, step : float):
	x_count += 1
	z_count += 1
	var result = []
	result.resize(x_count * z_count)
	
	var rng = RandomNumberGenerator.new()
	
	rng.seed = hash(Time.get_datetime_dict_from_system())
		
	for x in x_count:
		for z in z_count:
			var height = rng.randf_range(0, 1)
#			height = 0
			result[x * x_count + z] = Vector3(x * step, height, z * step)

			
	return result
	
	
func _generate():
	var width_s = pow(2, smoothing) + 1
	var depth_s = pow(2, smoothing) + 1
	
	var heightmapGenerator = DiamondSquare.new()
#	default_seed = str(OS.get_time()) if is_random_seed else "Something"
#111fgsdf
	if is_random_seed: default_seed = str(Time.get_unix_time_from_system())
	var heights = heightmapGenerator.generate(Vector2(width_s, depth_s), roughness, hash(default_seed))
#	var vertices = _generate_heightmap(width_s, depth_s, 1)

	var vertices = []
	vertices.resize(width_s * depth_s)

	for x in width_s:
		for z in depth_s:
			var index : int  = _get_1d_from_2d(x, z, width_s, depth_s)
			vertices[index] = Vector3(x / width_s * width, heights[x][z] * height, z / depth_s * depth)
			
	vertx = vertices		
#	var noise = OpenSimplexNoise.new()
#	for i in vertices.size():
#		vertices[i].y = noise.get_noise_2d(vertices[i].x, vertices[i].z) * 32

	width_s -= 1
	depth_s -= 1
	var indices = []
	indices.resize(width_s * depth_s * 6)
	
	var vert : int = 0
	var ind : int = 0
	for x in width_s:
		for z in depth_s:
			indices[ind + 0] = vert + 0
			indices[ind + 1] = vert + depth_s + 1
			indices[ind + 2] = vert + 1
			indices[ind + 3] = vert + depth_s + 1
			indices[ind + 4] = vert + depth_s + 2
			indices[ind + 5] = vert + 1
		
			vert += 1
			ind += 6
		vert += 1
	
	build_mesh(vertices, indices)
	
	
	water_mesh_instance.global_transform.origin = Vector3(width / 2, sea_level, depth / 2)
	water_mesh_instance.scale = Vector3(width / 2, 1, depth / 2)
	
	var textureRect = $"Control/TextureRect"
#	textureRect.update_with_heights(heights)


#func _process(delta):
#	if Engine.is_editor_hint():
#		if Input.is_key_pressed(KEY_ALT):
#			_generate()
			
		
		
