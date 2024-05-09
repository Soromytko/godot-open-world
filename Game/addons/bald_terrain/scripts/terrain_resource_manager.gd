extends Node


const class_terrain_data = preload("./terrain_data.gd")

var path = null:
	get:
		return path
	set(value):
		path = value

var data : class_terrain_data:
	get:
		return data
	set(value):
		data = value

const file_names = {
	terrain_data = "terrain_data.tres",
	heightmap_image = "heightmap_image.res",
	main_texture = "main_texture.jpg",
}


func is_path_valid() -> bool:
	return path != null && DirAccess.open(path) != null


func try_load_terrain_data() -> bool:
	if not is_path_valid():
		return false
	if not ResourceLoader.exists(path + "/" + file_names.terrain_data):
		return false
	data = load(_get_path_to_file(file_names.terrain_data))
	return data != null


func try_save_terrain_data() -> bool:
	if not is_path_valid():
		return false
	if data == null:
		return false
	ResourceSaver.save(data, _get_path_to_file(file_names.terrain_data))
	ResourceSaver.save(data.heightmap_image, _get_path_to_file(file_names.heightmap_image))
	return true


func try_create_terrain_data(image_size : Vector2i) -> bool:
	var terrain_data := class_terrain_data.new()
	terrain_data.heightmap_image = _create_heightmap(image_size)
	terrain_data.main_texture = _create_main_texture(image_size)
	data = terrain_data
	return true


func resize_heightmap(size : Vector2i) -> bool:
	if data == null:
		return false
	var heightmap : Image = data.heightmap_image
	if heightmap == null:
		return false
	var size_ratio : float = size.length() / heightmap.get_size().length()
	heightmap.resize(size.x, size.y)
	for i in heightmap.get_width():
		for j in heightmap.get_height():
			var color : Color = heightmap.get_pixel(i, j)
			color.r *= size_ratio
			heightmap.set_pixel(i, j, color)
	return true


func _get_path_to_file(file_name : String) -> String:
	return path + "/" + file_name


func _create_heightmap(size : Vector2i) -> Image:
	var image : Image = Image.create(size.x, size.y, false, Image.FORMAT_RF)
	image.fill(Color.BLACK)
	return image


func _create_main_texture(size : Vector2i) -> ImageTexture:
	var image : Image = Image.create(size.x, size.y, false, Image.FORMAT_RGB8)
	image.fill(Color.GREEN_YELLOW)
	var texture : ImageTexture = ImageTexture.create_from_image(image)
	return texture
