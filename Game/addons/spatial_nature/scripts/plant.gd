@tool
extends Resource

@export_group("Octree")
@export var size : Vector3 = Vector3.ONE * 100
@export var max_depth : int = 3
@export var node_capacity : int = 5

@export_group("LOD")
## LOD update rate in seconds
@export var lod_update_rate : float = 0.5
@export var max_lod_distance : float = 2.0
@export var is_killable_by_distance : bool = true
@export var lod_variants : Array[Resource]
