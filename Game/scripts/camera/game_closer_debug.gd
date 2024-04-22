extends Node


func _input(event):
	if OS.is_debug_build():
		if event is InputEventKey:
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()

