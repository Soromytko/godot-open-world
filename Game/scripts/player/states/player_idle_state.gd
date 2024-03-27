class_name PlayerIdleState extends PlayerState

func _on_enter():
	_play_anim("idle")
	

func _on_physics_update(delta):
	if !player.is_on_floor():
		player.apply_gravity(delta)
	player.apply_velocity()
	
#	if !player.is_on_floor():
#		return _switch_state("FALL")
	
	var input = player.get_input()
	if input != Vector3.ZERO:
		return _switch_state("PlayerWalkState")
		
	if Input.is_action_just_pressed("jump"):
		return _switch_state("PlayerJumpState")
		
