extends "./player_state.gd"


func _on_physics_update(delta : float):
	var relative_input : Vector3 = _get_input_relative_camera()
	
	player_movement_controller.apply_gravity(delta)
	player_movement_controller.rotate_to_direction(relative_input, delta * 0.5)
	player_movement_controller.move_with_delta(Vector3.ZERO, 0, delta)
	
	if player_movement_controller.character_body.velocity.y > 0:
		_switch_state(State.jump)
	elif player_movement_controller.is_grounded():
		_switch_state(State.idle)
