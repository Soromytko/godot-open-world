extends Resource


var id : int = -1:
	get:
		return id
@export var is_stackable : bool = true:
	get:
		return is_stackable
@export var icon : Texture2D = preload("../resources/icons/icon.png"):
	get:
		return icon
