class_name Player extends CharacterBody3D

signal move_event(position)

@export var camera : ThirdPersonCamera

@export var walk_speed : float = 10
@export var sprint_speed : float = 30
@export var rotation_speed : float = 10
@export var jump_force : float = 25
@export var gravity : float = 5

var handle_speed = walk_speed
var move_direction = Vector3.ZERO
var stamina_bar_value : float = 1
const G = 9.8

var _direction = Vector3.ZERO


func take_damage(damage : int):
	var health = get_node("/root/Spatial/Control/Health/Bar")
	health.rect_scale.x -= damage * 0.01
	clamp(health.rect_scale.x, 0, 100)
	

func get_input() -> Vector3:
	var input = Vector3.ZERO
	input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return input.normalized() if input.length() > 1 else input


func move(speed : float):
	velocity.x = _direction.x * speed
	velocity.z = _direction.z * speed
	move_and_slide()
	camera.follow(transform.origin)
	
	
var is_build_mode = false
func set_build_mode(active):
	var axe_cur = $Hand.get_node("Axe")
	if axe_cur != null:
		axe_cur.visible = !active
	is_build_mode = active
	
	
func jump():
	if(is_on_floor()):
		velocity.y += jump_force
		
		
func set_move_direction(direction : Vector3):
	_direction = direction
	
	
func apply_jump(force : float = jump_force):
	velocity.y += force	
	
	
func apply_gravity(force : float = gravity):
	velocity.y -= force * G
	
	
func apply_velocity(velocity : Vector3 = self.velocity):
	self.velocity = velocity
	move_and_slide()
	_move_camera()
	

func rotate_to_direction(direction : Vector3, speed : float):
	rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), rotation_speed * speed)
	
	
func _move_camera(target : Vector3 = self.transform.origin):
	if camera: camera.follow(target)
	
	
func _input(event):
	if Input.is_action_just_pressed("Click") and not is_build_mode:
		if $Hand.get_child_count() > 0:
			if $RayCast.is_colliding():
				var collider = $RayCast.get_collider()
				if collider is TreeWooden:
					collider.destroy()
				elif collider is Enemy:
					collider.queue_freeА 
		
		
func _ready():
	if !camera:
		camera = get_node("/root/Node3D/ThirdPersonCamera")
		
		
func _process(delta):
#	var stamina = get_node("/root/Spatial/Control/Stamina/Bar")
	
	if Input.is_action_pressed("sprint"):
		stamina_bar_value = move_toward(stamina_bar_value, 0, delta / 2)
		if stamina_bar_value > 0:
			handle_speed = sprint_speed
		else:
			handle_speed = walk_speed
	else:
		stamina_bar_value = move_toward(stamina_bar_value, 1, delta / 5)
	if Input.is_action_just_released("sprint"):
		handle_speed = walk_speed
		
#	stamina.rect_scale.x = stamina_bar_value

func get_relative_input(input : Vector3):
	if camera:
		return camera.transform.basis.x * input.x + camera.transform.basis.z * input.z
	return input


#@preload var 
var is_build = true
func _physics_process(delta):
#	if is_build:
		
	pass
	
