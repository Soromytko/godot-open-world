class_name OWChunkManager extends Node3D

@export var chunk_scene : PackedScene

func load_chunk(chunk_index : Vector3i) -> OWChunk:
	if chunk_scene == null:
		push_warning("Chunk scene is empty")
		return null
	var chunk : OWChunk = chunk_scene.instantiate()
	add_child(chunk)
	return chunk
