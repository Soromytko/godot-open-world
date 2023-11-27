class_name Equipment
extends RigidBody3D
		
func playA():
	$AnimationPlayer.playback_speed = 2
	$AnimationPlayer.play("Axe")

func _process(delta):
	if get_parent().name == "Hand":
		if Input.is_action_just_pressed("Click"):
			playA()
