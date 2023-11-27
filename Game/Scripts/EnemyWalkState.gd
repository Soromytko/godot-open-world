class_name EnemyWalkState extends EnemyState

func _on_enter():
	return
		
func _on_update(delta):
	_enemy.animation_player.playback_speed = 1
	_enemy.animation_player.play("EnemyWalk")

	if _enemy._check_player():
		return self.State.PURSUIT

	if _enemy.nav_agent.distance_to_target() < 1 && _enemy.nav_agent.is_target_reachable():
		var rng = RandomNumberGenerator.new()
		var t = Time.get_unix_time_from_system()
		rng.seed = hash(str(t))
	#		rng.seed = hash("Godot")
	#		rng.state = 100
		var max_l = 10
		var new_location = Vector3(rng.randf_range(-max_l, max_l), rng.randf_range(-max_l, max_l), rng.randf_range(-max_l, max_l))
		new_location += _enemy.global_transform.origin
		new_location.y = _enemy.global_transform.origin.y
		_enemy.nav_agent.set_target_position(new_location)
		return _enemy.State.LOOK_AROUND
	else:
		var next_location = _enemy.nav_agent.get_next_path_position()
		var velocity = (next_location - _enemy.global_transform.origin).normalized() * _enemy.move_speed / 2
		_enemy.set_velocity(velocity)
		_enemy.set_up_direction(Vector3.UP)
		_enemy.move_and_slide()
		_enemy.velocity
		_enemy.rotation.y = lerp_angle(_enemy.rotation.y, atan2(velocity.x, velocity.z), 5 * delta)
	
	return self.state_name
	
func _on_exit():
	pass
