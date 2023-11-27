class_name BlockConstruction extends Builder

@export var phantom_block_path : String
@export var real_block_path : String
@onready var _phantom_block_scene = load(phantom_block_path)
@onready var _real_block_scene = load(real_block_path)

var _phantom_block
var _real_block

func _on_enter():
	_phantom_block = _phantom_block_scene.instantiate()
	get_tree().get_root().add_child(_phantom_block)
	
	
	
func _on_update(delta):
	if ray_cast.is_colliding():
		var point = ray_cast.get_collision_point()
		_phantom_block.global_position = point
		
		area.global_position = point
#		for body in area.get_overlapping_bodies():
#			if body is Construction:
#				point = body.get_nearest_point(point)
#				break
#
		if Input.is_action_just_pressed("Click"):
			var construction = _real_block_scene.instantiate()
			construction.global_position = point
			get_tree().get_root().add_child(construction)
		
		
func _on_exit():
	_phantom_block.queue_free()
