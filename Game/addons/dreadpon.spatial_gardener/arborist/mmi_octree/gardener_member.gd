@tool
extends StaticBody3D


signal destroyed(index : int)


var t : float
func _process(delta):
	t += delta
	if t >= 3:
		_destory()


func _destory():
	var index : int = _get_index()
	if index >= 0:
		destroyed.emit(index)


func _get_index() -> int:
	var i : int = 0
	for child in get_parent().get_children():
		if child == self:
			return i
		i += 1
	return -1
