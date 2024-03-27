extends "../movement_controller.gd"


@export var movement_speed : float = 1.5
@export var sprint_movement_speed : float = 3.0
@export var free_fall_movement_speed : float = 5.0
@export var sprint_speed : float = 15.0
@export var rotation_speed : float = 5.0
@export var jump_force : float = 4.0
@export var gravity_force : float = 9.8

var _relative_camera_rotation_helper : Node3D
var _last_grounded_movement_direction : Vector3
var _last_grounded_movement_speed : float


func _ready():
	_relative_camera_rotation_helper = Node3D.new()
	add_child(_relative_camera_rotation_helper)


func move_with_delta(direction : Vector3, speed : float, delta : float):
	if is_grounded():
		_last_grounded_movement_direction = direction
		_last_grounded_movement_speed = speed
	else:
		direction = _last_grounded_movement_direction
		speed = _last_grounded_movement_speed
	super.move(direction, speed * delta)


func move_forward(speed : float, delta : float):
	var direction : Vector3 = -global_basis.z
	move_with_delta(direction, speed, delta)


func go_forward(delta : float):
	move_forward(movement_speed * 100.0, delta)


func run_forward(delta : float):
	move_forward(sprint_movement_speed * 100.0, delta)


func is_grounded() -> bool:
	var result : bool = super.is_grounded()
	return result


func jump_if_grounded(is_jump_action : bool = true):
	if is_grounded() && is_jump_action:
		super.add_velocity(Vector3.UP, jump_force)


func apply_gravity(delta : float):
	super.add_velocity(Vector3.DOWN, delta * gravity_force)


func rotate_to_direction(direction : Vector3, delta : float):
	super.rotate_to_direction(direction, delta * rotation_speed)


func rotate_to_movement_direction(delta : float):
	var direction : Vector3 = character_body.velocity
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		super.rotate_to_direction(direction, delta)


func get_direction_relative_to_camera(direction : Vector3):
	var camera : Camera3D = _get_camera()
	if camera != null:
		_relative_camera_rotation_helper.rotation.y = camera.global_rotation.y
		var relative_basis : Basis = _relative_camera_rotation_helper.transform.basis
		return relative_basis.x * direction.x + relative_basis.z * direction.z
	return direction


func _get_camera() -> Camera3D:
	return get_viewport().get_camera_3d()

