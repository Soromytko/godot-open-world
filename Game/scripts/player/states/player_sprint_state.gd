extends "./player_state.gd"


func _on_enter():
	_play_anim("run")


func _on_physics_update(delta : float):
	var relative_input : Vector3 = _get_input_relative_camera()
	var is_jump_action : bool = class_player_input.get_is_jump()
	
	player_movement_controller.apply_gravity(delta)
	player_movement_controller.jump_if_grounded(is_jump_action)
	player_movement_controller.rotate_to_direction(relative_input, delta)
	player_movement_controller.run_forward(delta)
	
	if !player_movement_controller.is_grounded():
		_switch_state(State.fall)
	elif relative_input == Vector3.ZERO:
		_switch_state(State.idle)
	elif !class_player_input.get_is_sprint():
		_switch_state(State.walk)


