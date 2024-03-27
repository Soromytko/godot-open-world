extends RayCast3D

# var camera = get_node("/root/Spatial/CameraController")

@onready var player = get_node("/root/Node3D/Player")
@onready var inventory = get_node("/root/Node3D/Player/Inventory")

var wall_scene = preload("res://Prefabs/Wall.tscn")
var roof_scene = preload("res://Prefabs/Roof.tscn")

var is_build_mode = false
var wall_instance
var roof_instance
var brash # wall/roof

func _ready():
	wall_instance = wall_scene.instantiate()
	get_node("/root/Node3D").call_deferred("add_child", wall_instance)
	wall_instance.visible = false
	for child in wall_instance.get_children():
		if child is CollisionShape3D:
			child.disabled = true
	
	roof_instance = roof_scene.instantiate()
	get_node("/root/Node3D").call_deferred("add_child", roof_instance)
	roof_instance.visible = false
	for child in roof_instance.get_children():
		if child is CollisionShape3D:
			child.disabled = true
	
	brash = wall_instance
	
	
func _input(event):
	if event is InputEventKey:
		match event.keycode:
			KEY_1:
				is_build_mode = false
				print("build mode is disable")
				player.set_build_mode(false)
			KEY_2:
				print("build mode is enabled")
				is_build_mode = true
				player.set_build_mode(true)
			KEY_R:
				brash.visible = false
				brash = roof_instance
			KEY_T:
				brash.visible = false
				brash = wall_instance
				


func _build():
	var construction
	if brash == wall_instance:
		construction = wall_scene.instantiate()
	elif brash == roof_instance:
		construction = roof_scene.instantiate()
		
	remove()
	get_node("/root/Node3D").add_child(construction)
	construction.transform.origin = brash.transform.origin
	construction.rotation_degrees = brash.rotation_degrees
	
	
func get_count():
	if brash == wall_instance: return inventory.wood_count
	elif brash == roof_instance: return inventory.foliage_count
	return 0

func remove():
	if brash == wall_instance: inventory.remove_wood(2)
	elif brash == roof_instance: inventory.remove_foliage(2)

func _physics_process(delta):
	brash.visible = false
	if is_build_mode == false || get_count() < 2: return

	if is_colliding():
		var collider = get_collider()
		brash.transform.origin = get_collision_point()
		brash.rotation_degrees = get_parent().get_parent().get_parent().rotation_degrees
		brash.visible = true
		if Input.is_action_just_pressed("Click"):
			_build()
#			inventory.remove_wood(2)
#			var wall = wall_scene.instance()
#			get_node("/root/Spatial").add_child(wall)
#			wall.transform.origin = brash.transform.origin
#			wall.rotation_degrees = brash.rotation_degrees
