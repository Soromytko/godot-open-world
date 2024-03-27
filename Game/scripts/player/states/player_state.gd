class_name PlayerState extends StateMachineState

enum State {IDLE, FALL, JUMP, WALK, ON_GROUND, IN_FULL}

@export var player : Player
@export var animation_tree : AnimationTree

var anim_names : Array[String] = ["idle", "walk", "run"]

func _play_anim(name : String):
	var par : String = "parameters/conditions/"
	for anim_name in anim_names:
		var is_true_name = name == anim_name
		animation_tree.set(par + anim_name, is_true_name)
