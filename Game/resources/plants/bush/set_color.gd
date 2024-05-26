@tool
extends Label

@export var color : Color = Color.WHITE

func _process(delta):
	modulate = color
	
