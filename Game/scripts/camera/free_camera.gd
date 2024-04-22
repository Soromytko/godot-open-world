extends Camera3D

@export var speed : float = 10.0
@export var sensitivity : float = 0.2

var _rotation : Vector3 = Vector3.ZERO


func _get_input() -> Vector3:
	var input : Vector3 = Vector3.ZERO
	input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return input.normalized() if input.length() > 1 else input


func _input(event):
	if event is InputEventMouseMotion:
		_rotation.x += -event.relative.x * sensitivity
		_rotation.y += -event.relative.y * sensitivity
		_rotation.y = clamp(_rotation.y, -90, 90)
		rotation_degrees.x = _rotation.y
		rotation_degrees.y = _rotation.x
	if event is InputEventKey:
		match event.keycode:
			KEY_ESCAPE:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	


func _process(delta):
	var input : Vector3 = _get_input()
	var offset = transform.basis.x * input.x + transform.basis.z * input.z
	if Input.is_action_pressed("sprint"): offset *= 4
	elif Input.is_action_pressed("crouch"): offset /= 4
	global_transform.origin += offset * speed * delta
	
