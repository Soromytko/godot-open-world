class_name Enemy extends CharacterBody3D

@export var move_speed : float = 5

@onready var nav_agent = $"NavigationAgent3D"
@onready var raycast = $"RayCast3D"
@onready var animation_player = $"AnimationPlayer"

var target = null
var is_player_invisible : bool = false

func _input(event):
	if Input.is_action_just_pressed("Alt"):
		is_player_invisible = !is_player_invisible
		var player = get_node("/root/Node3D/Player/Skin")
		var material = player.get_surface_override_material(0)
#			print(material.transparency)
		if is_player_invisible:
			material.albedo_color = Color(1, 1, 1, 0.2)
		else:
			material.albedo_color = Color(1, 1, 1, 1)
		player.set_surface_override_material(0, material)


func move_to(target : Vector3):
	nav_agent.set_target_position(target)
	

func _ready():
	pass
#	nav_agent.set_navigation(get_node("/root/Node3D/Navigation"))
#	move_to(global_transform.origin)
	
#	fsm.add_state(EnemyWalkState.new(State.WALK, self))
#	fsm.add_state(EnemyPursueState.new(State.PURSUIT, self))
#	fsm.add_state(EnemyWalkState.new(State.LOOK_AROUND, self))
#
#	fsm.switch_state(State.WALK)
	

func _check_player():
	if is_player_invisible: return false
	
	if target != null:
		var target_look = target.global_transform.origin
		target_look.y = global_transform.origin.y
		raycast.look_at(target_look, Vector3.UP)
		if raycast.is_colliding():
			if raycast.get_collider() is Player:
				return true
			
	return false
	

func _on_Area_body_entered(body):
	if body is Player:
		target = body
		
	
func _on_Area_body_exited(body):
	if body is Player:
		target = null


func _on_Area2_body_entered(body):
	if body is Player:
		target.take_damage(10)
