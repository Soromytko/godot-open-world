extends StateMachineState


class State:
	static var idle : String = "PlayerIdleState"
	static var walk : String = "PlayerWalkState"
	static var sprint : String = "PlayerSprintState"
	static var jump : String = "PlayerJumpState"
	static var fall : String = "PlayerFallState"


const class_player_movement_controller = preload("../player_movement_controller.gd")
const class_player_input = preload("../player_input.gd")

@export var player_movement_controller : class_player_movement_controller
@export var animation_tree : AnimationTree

var _anim_names : Array[String] = ["idle", "walk", "run"]


func _get_input_relative_camera() -> Vector3:
	var input : Vector3 = class_player_input.get_move_axes()
	return player_movement_controller.get_direction_relative_to_camera(input)


func _play_anim(name : String):
	var parameters : String = "parameters/conditions/"
	for anim_name in _anim_names:
		var is_true_name = name == anim_name
		animation_tree.set(parameters + anim_name, is_true_name)
