extends Resource

@export var heightmap_image : Image:
	get:
		return heightmap_image
	set(value):
		heightmap_image = value

@export var main_texture : Texture:
	get:
		return main_texture
	set(value):
		main_texture = value

@export var uv_offset : Vector2 = Vector2.ONE * 0.5

