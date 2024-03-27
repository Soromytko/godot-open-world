class_name Brigadier extends Node3D

@export var state_machine : StateMachine

func _ready():
	pass
	
	
func _process(delta):
#	state_machine.switch_state("FoundationBuilder")
	state_machine.switch_state("BlockConstruction")
