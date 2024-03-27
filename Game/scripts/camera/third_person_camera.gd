extends Node3D

@export_group("Following")
@export var target : Node3D
@export var sharpness : float = 2.0 
@export_group("Rotation")
@export var sensitivity = 0.4
@export var acceleration = 20
@export var _minimum_angle = -80
@export var _maximum_angle = +75

var _instant_mouse = Vector2(0, 0)
var _smoothed_mouse = Vector2(0, 0)


func _ready():
	#Ensure that the camera is processed after the target moves
	process_physics_priority = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		_instant_mouse.x += -event.relative.x * sensitivity
		_instant_mouse.y += -event.relative.y * sensitivity
		_instant_mouse.y = clamp(_instant_mouse.y, _minimum_angle, _maximum_angle)
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
#			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	_process_rotation(delta)
	_follow_target(delta)


func _process_rotation(delta : float):
	var speed = acceleration * delta
	_smoothed_mouse.x = lerp(_smoothed_mouse.x, _instant_mouse.x, speed)
	_smoothed_mouse.y = lerp(_smoothed_mouse.y, _instant_mouse.y, speed)
	$Pivot.rotation_degrees.x = _smoothed_mouse.y
#	$Pivot.rotation_degrees.y = _smoothed_mouse.x
	rotation_degrees.y = _smoothed_mouse.x


func _follow_target(delta : float):
	if target != null:
		global_position = lerp(global_position, target.global_position, sharpness * delta)
