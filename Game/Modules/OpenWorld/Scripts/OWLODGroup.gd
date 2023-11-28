class_name OWLODGroup extends Node3D

var _lods : Array[Node3D]
var _current_lod_index : int


func _ready():
	_find_lods_by_names()
	
	
func _find_lods_by_names():
	_current_lod_index = 0
	var lod_name_regex = RegEx.new()
	lod_name_regex.compile("LOD+[0-9]+")
	var lod_number_regex = RegEx.new()
	lod_number_regex.compile("[0-9]+")
	for child in get_children():
		var maybe_lod_name : RegExMatch = lod_name_regex.search(child.name)
		if maybe_lod_name:
			var lod_name : String = maybe_lod_name.get_string()
			var maybe_lod_number : RegExMatch = lod_number_regex.search(lod_name)
			if maybe_lod_number:
				var lod_number : String = maybe_lod_number.get_string()
				var index : int = lod_number.to_int()
				if _lods.size() <= index:
					_lods.resize(index)
				_lods.insert(index, child)
				child.visible = index == 0
	
	

func set_LOD(level : int):
	if level != _current_lod_index:
		_get_LOD_object(_current_lod_index).visible = false
		_get_LOD_object(level).visible = true
		_current_lod_index = level
		

func _get_LOD_object(level : int):
	var normal_level : int = clamp(level, 0, _lods.size() - 1)
	return _lods[normal_level]
