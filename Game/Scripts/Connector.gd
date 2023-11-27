extends Node

@export onready var player = get_node("/root/Node3D/Player")
@export onready var camera = get_node("/root/Node3D/CameraController")

func getPlayer():
	print("yes")
	pass

func _ready():
	player.connect("move_event", Callable(camera, "on_follow"))
	
