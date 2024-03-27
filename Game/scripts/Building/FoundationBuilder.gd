class_name FoundationBuilder extends Builder

var _vertical_beam_scene = preload("res://Prefabs/Building/Foundation/VerticalBeam.tscn")
var _floor_scene = preload("res://Prefabs/Building/Foundation/Floor.tscn")
var _beams : Array[Beam]
var _floor

#func build():
#	print("build Foundation")
#
#
#func process_build(point : Vector3):
#	pass

enum State {ONE, TWO, THREE}

var current_state = State.ONE

func _on_enter():
	_floor = _floor_scene.instantiate()
	
	for i in 4:
		var beam = _vertical_beam_scene.instantiate()
		beam.set_process(false)
		beam.visible = false
		_beams.append(beam)
		get_tree().get_root().add_child(beam)
		
	get_tree().get_root().add_child(_floor)
	
	_beams[0].set_process(true)
	_beams[0].visible = true
	
	
func _on_update(delta):
	if ray_cast.is_colliding():
		var point = ray_cast.get_collision_point()
		match current_state:
			State.ONE:
				_beams[0].global_transform.origin = point
				if Input.is_action_just_pressed("Click"):
					current_state = State.TWO
					for beam in _beams:
						beam.set_process(true)
						beam.visible = true
					_floor.set_process(true)
					_floor.visible = true
			State.TWO:
				_beams[1].global_position = Vector3(_beams[0].global_position.x, point.y, point.z)
				_beams[2].global_position = Vector3(point.x, point.y, _beams[0].global_position.z)
				_beams[3].global_transform.origin = point
				
				var floor_pos = (_beams[0].global_position + _beams[3].global_position) / 2
				floor_pos.y = _beams[0].global_position.y + _beams[0].length
				_floor.global_position = floor_pos
				_floor.scale.x = abs(_beams[3].global_position.x - _beams[0].global_position.x)
				_floor.scale.z = abs(_beams[3].global_position.z - _beams[0].global_position.z)
				var height = _beams[0].global_position.y + _beams[0].length - point.y
				if height > 0:
					_beams[1].length = height
					_beams[2].length = height
					_beams[3].length = height
					if Input.is_action_just_pressed("Click"):
						current_state = State.THREE
						_beams[3].set_process(false)
			State.THREE:
				return
				print(get_children().size())
					
		
	
	
func _on_exit():
	_beams[0].queue_free()
	_beams[3].queue_free()
