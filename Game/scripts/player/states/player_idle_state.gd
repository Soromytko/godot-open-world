extends "./player_state.gd"


func _on_enter():
	_play_anim("idle")


func _on_physics_update(delta : float):
	player_movement_controller.apply_gravity(delta)
	player_movement_controller.move(Vector3.ZERO, delta)
	
	if !player_movement_controller.is_grounded():
		_switch_state(State.fall)
	elif class_player_input.get_move_axes() != Vector3.ZERO:
		_switch_state(State.walk)
	elif class_player_input.get_is_jump():
		player_movement_controller.jump_if_grounded()
		#_switch_state(State.jump)


