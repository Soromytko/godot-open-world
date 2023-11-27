extends DirectionalLight3D

@export var speed : float = 100.0

func _ready():
	pass # Replace with function body.


func _process(delta):
	rotation_degrees.x += speed * delta
