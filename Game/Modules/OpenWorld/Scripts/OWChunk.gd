class_name OWChunk extends Node


var _current_child_index : int = 0
var _current_observer_distance : float = 0


var _lod_ranges = [
	5.0,
	10.0,
	20.0,
	30.0,
]


func set_LOD_by_distance(distance : float):
	_current_observer_distance = distance
	
	
func _get_LOD_by_distance(distance : float):
	var level : int = _lod_ranges.size() - 1
	for i in range(0, _lod_ranges.size()):
		if distance <= _lod_ranges[i]:
			level = i
			break
	return level


func _process(delta):
	var level : int = _get_LOD_by_distance(_current_observer_distance)
	var children : Array[Node] = get_children()
	if children.size() >= _current_child_index:
		var child = children[_current_child_index]
		if child is OWLODGroup:
			var lod : OWLODGroup = child
			lod.set_LOD(level)
	else:
		_current_child_index = 0

