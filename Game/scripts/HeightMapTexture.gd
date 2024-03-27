@tool
extends TextureRect

func update_with_heights(heights):
	var image = Image.new()
	image.create(heights.size(), heights[0].size(), false, Image.FORMAT_RGB8)
	
	false # image.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	for i in heights.size():
		for j in heights[i].size():
			var channel = heights[i][j]
			image.set_pixel(i, j, Color(channel, channel, channel, 1))
	false # image.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	
	 
#	image.fill(Color(1,1,1))
	
	var imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image)
	self.texture = imageTexture
		
