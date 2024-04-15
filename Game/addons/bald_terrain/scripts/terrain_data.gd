

var heightmap_image : Image:
	get:
		return heightmap_image
	set(value):
		heightmap_image = value

var main_texture : Texture:
	get:
		return main_texture
	set(value):
		main_texture = value


func validate_data() -> bool:
	if heightmap_image == null:
		print("terrain heightmap is null")
		return false
	return true

