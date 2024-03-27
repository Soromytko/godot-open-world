class_name Beam extends Node3D

var length : float:
	get:
		return scale.y
	set(value):
		length = value
		var new_scale = scale
		new_scale.y = value
		scale = new_scale

	
