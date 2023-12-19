class_name TerrainChunk extends Node3D

var width : int = 10
var depth : int = 10

@export var grass : MultiMeshInstance3D

func update_mesh(mesh):
	$MeshInstance3D.mesh = mesh
	
	
func update_shape(shape):
	$CollisionShape3D.shape = shape


func generate_mesh(size : Vector3i, offset : Vector3i, noise : Noise):
	width = size.x
	depth = size.z
	var width_s = width + 1
	var depth_s = depth + 1
	var vertices = []
	vertices.resize(width_s * depth_s)
	for x in width_s:
		for z in depth_s:
			var w = x - width / 2
			var h : float = noise.get_noise_2d(x + offset.x, z + offset.z) * 15
			var d = z - depth / 2
			vertices[x * width_s + z] = Vector3(w, h, d)
			
	var indices = []
	indices.resize(width * depth * 6)
	var vert : int = 0
	var ind : int = 0
	for x in width:
		for z in depth:
			indices[ind + 0] = vert + 0
			indices[ind + 1] = vert + depth_s
			indices[ind + 2] = vert + 1
			indices[ind + 3] = vert + depth_s
			indices[ind + 4] = vert + depth_s + 1
			indices[ind + 5] = vert + 1
		
			vert += 1
			ind += 6
		vert += 1
		
	_build_mesh(vertices, indices)
		
		
func _build_mesh(vertices, indices):
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
	
	$MeshInstance3D.mesh = surface_tool.commit()
	
	$CollisionShape3D.shape = array_mesh.create_trimesh_shape()
