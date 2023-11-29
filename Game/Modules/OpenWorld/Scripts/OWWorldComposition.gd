class_name OWWorldComposition extends Node3D

@export var chunk_manager : OWChunkManager
@export var observer : Node3D
@export var chunk_size : Vector3i
@export var viewing_radius : float = 10
var _chunks : Dictionary
var _current_observer_chunk_index : Vector3i

func _ready():
	_process(0)
	
	
func _process(delta):
	if observer == null:
		push_warning("Observer is null")
		return
	if chunk_manager == null:
		push_warning("ChunkManager is null")
		return
	
	var chunk_index : Vector3i = _get_chunk_index_by_position(observer.global_position)
	if _current_observer_chunk_index != chunk_index:
		_update_chunks(chunk_index)
		_current_observer_chunk_index = chunk_index
		
		
func _update_chunks(chunk_index : Vector3i):
	_clear_unobservable_chunks(chunk_index)
	_create_observable_chunks(chunk_index)
	
	
func _create_observable_chunks(observer_chunk_index : Vector3i):
#	if !_chunks.has(Vector3i.ZERO):
#		var chunk = chunk_manager.load_chunk(Vector3i.ZERO)
#		_chunks[Vector3i.ZERO] = chunk
#		chunk.global_position = Vector3.ZERO
#	return
#
	var chunk_position : Vector3 = _get_chunk_position_by_index(observer_chunk_index)
	var start_chunk_index : Vector3i = _get_chunk_index_by_position(chunk_position - Vector3.ONE * viewing_radius)
	var end_chunk_index : Vector3i = _get_chunk_index_by_position(chunk_position + Vector3.ONE * viewing_radius)
	start_chunk_index.y = 0
	end_chunk_index.y = 1
	for x in range(start_chunk_index.x, end_chunk_index.x, 1):
		for y in range(start_chunk_index.y, end_chunk_index.y, 1):
			for z in range(start_chunk_index.z, end_chunk_index.z, 1):
				var current_chunk_index : Vector3i = Vector3i(x, y, z)
				var current_chunk_position = _get_chunk_position_by_index(current_chunk_index)
				if current_chunk_position.distance_to(chunk_position) <= viewing_radius:
					if !_chunks.has(current_chunk_index):
						var chunk : OWChunk = chunk_manager.load_chunk(current_chunk_index)
						if chunk != null:
							chunk.global_position = current_chunk_position
							_chunks[current_chunk_index] = chunk
	


func _clear_unobservable_chunks(observer_chunk_index : Vector3i):
	var chunk_position = _get_chunk_position_by_index(observer_chunk_index)
	var deletion_queue : Array[Vector3i]
	for current_chunk_index in _chunks:
		var current_chunk_position : Vector3 = _get_chunk_position_by_index(current_chunk_index)
		var distance : float = current_chunk_position.distance_to(chunk_position)
		_chunks[current_chunk_index].set_LOD_by_distance(distance)
		if distance > viewing_radius:
			deletion_queue.append(current_chunk_index)
	return
	for current_chunk_index in deletion_queue:
		var chunk : OWChunk = _chunks[current_chunk_index]
		chunk.queue_free()
		_chunks.erase(current_chunk_index)
	

func _get_chunk_index_by_position(position : Vector3) -> Vector3i:
	var point : Vector3 = position
	if point.x < 0: point.x -= chunk_size.x
	if point.y < 0: point.y -= chunk_size.y
	if point.z < 0: point.z -= chunk_size.z
	var x : float = point.x / chunk_size.x
	var y : float = point.y / chunk_size.y
	var z : float = point.z / chunk_size.z
	return Vector3i(x, y, z)


func _get_chunk_position_by_index(chunk_index : Vector3i) -> Vector3:
	return chunk_index * chunk_size
