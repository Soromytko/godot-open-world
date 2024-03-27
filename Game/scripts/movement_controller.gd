extends Node3D


@export var character_body : CharacterBody3D


var _velocity : Vector3:
	get:
		return character_body.velocity
	set(value):
		character_body.velocity = value


func move(direction : Vector3, speed : float):
	character_body.velocity.x = direction.x * speed
	character_body.velocity.z = direction.z * speed
	character_body.move_and_slide()


func add_velocity(direction : Vector3, speed : float):
	character_body.velocity += direction * speed


func is_grounded() -> bool:
	return character_body.is_on_floor()


func rotate_to_direction(direction : Vector3, speed : float):
	if direction == Vector3.ZERO:
		return
	var rotation_target : float = atan2(-direction.x, -direction.z)
	character_body.rotation.y = lerp_angle(character_body.rotation.y, rotation_target, speed)

