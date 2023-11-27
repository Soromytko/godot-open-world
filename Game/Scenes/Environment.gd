extends Node3D

var tree_scene = preload("res://Prefabs/Tree.tscn")
#var enemy_scene = preload("res://Prefabs/Enemy.tscn")
@export var tree_density = 3

var trees = []
func _ready():
	
	$Terrain.generateM(true)
	var vertices = $Terrain.vertx
	
	var rng = RandomNumberGenerator.new()
	rng.seed = hash("Godot")
	rng.state = 100
	for i in $Terrain.width * $Terrain.width / 10000 * tree_density:
		var tree = tree_scene.instantiate()
		get_node("/root/Node3D").call_deferred("add_child", tree)
		var v = rng.randi_range(0, vertices.size() - 1)
		tree.transform.origin = vertices[v]
		trees.append(tree)
		
	var v = rng.randi_range(0, vertices.size() - 1)
	get_node("/root/Node3D/Player").global_transform.origin = vertices[v]
	
#	for i in 10:
#		var enemy = enemy_scene.instantiate()
#		get_node("/root/Node3D/Navigation").call_deferred("add_child", enemy)
#		v = rng.randi_range(0, vertices.size() - 1)
#		enemy.transform.origin = vertices[v]
		
	
	
	
