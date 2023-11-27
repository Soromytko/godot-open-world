class_name EnemyState extends StateMachineState

@export var _enemy : Enemy

enum State { WALK, PURSUIT, LOOK_AROUND }


func _init(state_name, enemy : Enemy):
	super(state_name)
	_enemy = enemy
	


