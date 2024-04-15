

var meshes = null:
	get: return meshes

var mesh_subdivision : int = 16:
	get: return mesh_subdivision

const _mesh_size : Vector2 = Vector2.ONE
var _vertex_step : Vector2

func create_meshes(mesh_subdivision : int = 16):
	self.mesh_subdivision = mesh_subdivision
	_vertex_step = _mesh_size / (mesh_subdivision + 2)
	#array[2][2][2][2]
	meshes = [[[[]]]]

	meshes.resize(2)
	for left_index in meshes.size():
		meshes[left_index] = [[[]]]
		meshes[left_index].resize(2)
		for right_index in meshes[left_index].size():
			meshes[left_index][right_index] = [[]]
			meshes[left_index][right_index].resize(2)
			for back_index in meshes[left_index][right_index].size():
				meshes[left_index][right_index][back_index] = []
				meshes[left_index][right_index][back_index].resize(2)
				for forward_index in meshes[left_index][right_index][back_index].size():
					var mesh : Mesh = PlaneMesh.new()
					mesh.size = _mesh_size
					mesh.subdivide_width = mesh_subdivision
					mesh.subdivide_depth = mesh_subdivision
					var array_mesh : ArrayMesh = ArrayMesh.new()
					array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh.get_mesh_arrays())
					var mesh_data_tool : MeshDataTool = MeshDataTool.new()
					mesh_data_tool.create_from_surface(array_mesh, 0)
					var vertex_step : float = 1.0 / (mesh_subdivision + 1)
					for i in mesh_data_tool.get_vertex_count():
						var vertex_color : Color = Color.GREEN
						var current_vertex : Vector3 = mesh_data_tool.get_vertex(i)
						var current_vertex_uv : Vector2 = mesh_data_tool.get_vertex_uv(i)
						current_vertex_uv = _offset_uv_by_half_vertex(current_vertex_uv)
						#mesh_data_tool.set_vertex_uv(i, current_vertex_uv)
						if left_index == 1:
							if _average_vertex_if_needed(current_vertex, -0.5):
								mesh_data_tool.set_vertex(i, current_vertex + Vector3.FORWARD * vertex_step)
								#mesh_data_tool.set_vertex_uv(i, current_vertex_uv + Vector2.UP * vertex_step)
						if right_index == 1:
							if _average_vertex_if_needed(current_vertex, +0.5):
								mesh_data_tool.set_vertex(i, current_vertex + Vector3.FORWARD * vertex_step)
								#mesh_data_tool.set_vertex_uv(i, current_vertex_uv + Vector2.UP * vertex_step)
						if back_index == 1:
							if _average_vertex_if_needed(current_vertex, -0.5, true):
								mesh_data_tool.set_vertex(i, current_vertex + Vector3.RIGHT * vertex_step)
								#mesh_data_tool.set_vertex_uv(i, current_vertex_uv + Vector2.RIGHT * vertex_step)
						if forward_index == 1:
							if _average_vertex_if_needed(current_vertex, +0.5, true):
								mesh_data_tool.set_vertex(i, current_vertex + Vector3.RIGHT * vertex_step)
								#mesh_data_tool.set_vertex_uv(i, current_vertex_uv + Vector2.RIGHT * vertex_step)
						mesh_data_tool.set_vertex_color(i, vertex_color)
					array_mesh.clear_surfaces()
					mesh_data_tool.commit_to_surface(array_mesh)
					
					#var surface_tool = SurfaceTool.new()
					#surface_tool.create_from(array_mesh, 0)
					#surface_tool.generate_normals()
					#mesh = surface_tool.commit()
					#meshes[left_index][right_index][back_index][forward_index] = mesh
					
					meshes[left_index][right_index][back_index][forward_index] = array_mesh
	return meshes


# Offset uv coordinated to 
func _offset_uv_by_half_vertex(uv : Vector2) -> Vector2:
	var length : float = uv.length()
	if length >= 0:
		var normalized_uv : Vector2 = uv / length
		var offset_direction : Vector2 = -normalized_uv
		uv += offset_direction * _vertex_step
	return uv


func _average_vertex_if_needed(vertex : Vector3, value : float, inverse_xz : bool = false) -> bool:
	var inverse_vertex : Vector3 = Vector3(vertex.z, vertex.y, vertex.x) if inverse_xz else vertex
	return _is_need_average(inverse_vertex, value)


func _is_need_average(vertex : Vector3, value : float) -> bool:
	return is_equal_approx(vertex.x, value) && \
		int((vertex.z + 0.5) * (mesh_subdivision + 1)) % 2 != 0

