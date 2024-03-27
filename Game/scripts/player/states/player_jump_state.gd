class_name PlayerJumpState extends PlayerState

func _on_enter():
	player.apply_jump()
	player.apply_velocity()
	
	
func _on_physics_update(delta):
	player.apply_gravity(delta)
	player.apply_velocity()
	
	if player.is_on_floor():
		return _switch_state("PlayerIdleState")
