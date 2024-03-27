class_name StateMachineState extends Node

signal transitioned

func _switch_state(state_name):
	emit_signal("transitioned", state_name)


func _on_enter():
	pass


func _on_update(delta):
	pass

	
func _on_physics_update(delta):
	pass


func _on_exit():
	pass
