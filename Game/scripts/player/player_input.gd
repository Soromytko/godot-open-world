static func get_move_axes() -> Vector3:
	var input = Vector3.ZERO
	input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return input.normalized() if input.length() > 1 else input


static func get_is_jump() -> bool:
	return Input.get_action_strength("jump") == 1


static func get_is_sprint() -> bool:
	return Input.get_action_strength("sprint") == 1

