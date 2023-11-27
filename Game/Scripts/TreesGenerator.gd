extends Node

var tree_scene = preload("res://Prefabs/Tree.tscn")

var trees = []
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	rng.state = 100
	for i in 5:
		var tree = tree_scene.instantiate()
		get_node("/root/Node3D").call_deferred("add_child", tree)
		tree.transform.origin.x = rng.randf_range(-50, 50)
		tree.transform.origin.y = 0
		tree.transform.origin.z = rng.randf_range(-50, 50)
#		print(tree.get_parent())
		trees.append(tree)
