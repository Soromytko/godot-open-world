class_name OWLODGroup extends Node3D

@export var LODs : Array[Node3D]

var _current_lod : Node3D

func _ready():
	_current_lod = LODs[0]
	

func set_LOD(level : int):
	var lod : Node3D = _get_LOD_object(level)
	if lod != _current_lod:
		_current_lod.visible = false
		_current_lod = lod
		_current_lod.visible = true
		

func _get_LOD_object(level : int):
	var normal_level : int = clamp(level, 0, LODs.size() - 1)
	return LODs[normal_level]
