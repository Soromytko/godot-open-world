class_name EnemyPursueState extends EnemyState

func _on_enter():
	pass
	
func _on_update(delta):
	_enemy.animation_player.playback_speed = 2
	_enemy.animation_player.play("EnemyWalk")

	if _enemy._check_player():
		_enemy.nav_agent.set_target_location(_enemy.target.global_transform.origin)

#	if nav_agent.is_target_reachable() && nav_agent.distance_to_target() > 1:
	if _enemy.nav_agent.distance_to_target() > 1:
		var next_location = _enemy.nav_agent.get_next_location()
		var velocity2 = (next_location - _enemy.global_transform.origin).normalized() * _enemy.move_speed
		_enemy.move_and_slide()
		_enemy.rotation.y = lerp_angle(_enemy.rotation.y, atan2(velocity2.x, velocity2.z), 5 * delta)

#		var velocity = global_transform.origin.direction_to(target).normalized() * move_speed
	#	https://godotengine.org/article/navigation-server-godot-4-0/
		_enemy.nav_agent.set_velocity(velocity2)

	else:
		return State.WALK
