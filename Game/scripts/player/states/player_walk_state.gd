class_name PlayerWalkState extends PlayerState

var _jump_force : float = 0.3

func _on_enter():
	_play_anim("walk")
	

func _on_update(delta):
	var input = player.get_input()
	var relative_input = player.get_relative_input(input)
	
	if Input.is_action_pressed("sprint"):
		_play_anim("run")
	else: _play_anim("walk")
	
	if player.is_on_floor():
		if Input.is_action_just_pressed("jump"):
			_switch_state("PlayerJumpState")
	else:
		player.apply_gravity(delta)

	player.set_move_direction(relative_input)
	var move_speed = player.sprint_speed if Input.is_action_pressed("sprint") else player.walk_speed
	player.move(delta * move_speed * 100)
	if input != Vector3.ZERO:
		player.rotate_to_direction(relative_input, delta)
	else:
		_switch_state("PlayerIdleState")
		

	
