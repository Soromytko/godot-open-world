class_name ThirdPersonCamera extends Node3D

@export var sensitivity = 0.4
@export var acceleration = 20
@export var v_min = -80
@export var v_max = +75
var _instant_mouse = Vector2(0, 0)
var _smoothed_mouse = Vector2(0, 0)

func follow(point : Vector3):
	transform.origin = lerp(transform.origin, point, 0.1)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		_instant_mouse.x += -event.relative.x * sensitivity
		_instant_mouse.y += -event.relative.y * sensitivity
		_instant_mouse.y = clamp(_instant_mouse.y, v_min, v_max)
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
#			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
func _physics_process(delta):
	var speed = acceleration * delta
	_smoothed_mouse.x = lerp(_smoothed_mouse.x, _instant_mouse.x, speed)
	_smoothed_mouse.y = lerp(_smoothed_mouse.y, _instant_mouse.y, speed)
	$Pivot.rotation_degrees.x = _smoothed_mouse.y
#	$Pivot.rotation_degrees.y = _smoothed_mouse.x
	rotation_degrees.y = _smoothed_mouse.x
