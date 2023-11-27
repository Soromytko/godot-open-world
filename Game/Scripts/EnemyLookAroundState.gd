class_name EnemyLookAroundState extends EnemyState

var looking_time : float = 5

func _on_update(delta):
	_enemy.animation_player.playback_speed = 2
	_enemy.animation_player.play("EnemyIdle")

	if looking_time <= 0:
		looking_time = 5
		return State.WALK
		return
	else:
		looking_time -= delta


	if _enemy._check_player():
		return State.PURSUIT
