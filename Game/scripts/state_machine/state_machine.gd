class_name StateMachine extends Node


@export var initial_state : StateMachineState

var states = {}
var current_state_name : String
var current_state : StateMachineState


func _ready():
	for child in get_children():
		if child is StateMachineState:
			child.transitioned.connect(_on_switch_state)
			add_state(child.name, child)
			if initial_state == child:
				current_state = initial_state
#				switch_state(child.name)


func add_state(name, state : StateMachineState):
	states[name] = state


func switch_state(name):
	if !states.has(name):
		print(name, "is a not state")
		return
	if current_state_name == name:
		return
		
	if current_state: current_state._on_exit()
	current_state = states[name]
	current_state._on_enter()
	current_state_name = name


func update(delta):
	if current_state:
		var new_state_name = current_state._on_update(delta)
		if states.has(new_state_name):
			var new_state = states[new_state_name]
			if new_state != current_state:
				switch_state(new_state_name)


func _on_switch_state(state_name):
	switch_state(state_name)


func _process(delta):
	if current_state:
		current_state._on_update(delta)


func _physics_process(delta):
	if current_state:
		current_state._on_physics_update(delta)

