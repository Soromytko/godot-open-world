shader_type spatial;

uniform sampler2D main_texture : source_color;
uniform sampler2D heightmap;
uniform float height = 1.0;
uniform float pixels_per_meter = 1.0;
uniform vec3 vertex_step = vec3(1.0);
uniform vec2 heightmap_uv_offset = vec2(0.5);
uniform vec2 main_texture_tiling = vec2(1.0);

vec3 get_world_vertex(vec3 vertex, mat4 model_matrix) {
	return (model_matrix * vec4(vertex, 1.0)).xyz;
}

vec2 get_world_vertex_uv(vec3 vertex) {
	// constants
	vec2 heightmap_size = vec2(textureSize(heightmap, 0));
	vec2 pixel_size = 1.0 / heightmap_size;
	// Shift the vertex by half a pixel
	vertex.xz += -vertex.xz * pixel_size;
	// Convert vertex to uv
	vec2 uv = vertex.xz / (heightmap_size * pixels_per_meter);
	uv += heightmap_uv_offset;
	// Clamp the uv to correctly calculate the normals at the edges
	uv.x = clamp(uv.x, 0.0, 1.0 - pixel_size.x);
	uv.y = clamp(uv.y, 0.0, 1.0 - pixel_size.y);
	
	return uv;
}

vec3 get_world_vertex_with_height(vec3 vertex, mat4 model_matrix) {
	vec3 world_vertex = get_world_vertex(vertex, model_matrix);
	vec2 uv = get_world_vertex_uv(world_vertex);
	world_vertex.y = texture(heightmap, uv).r * height;
	return world_vertex;
}

float get_vertex_height(vec3 world_vertex) {
	vec2 uv = get_world_vertex_uv(world_vertex);
	return texture(heightmap, uv).r * height;
}

vec3 get_vertex_normal(vec3 world_vertex, mat4 model_matrix) {
	vec3 right_vertex = world_vertex + vec3(vertex_step.x, 0.0, 0.0);
	vec3 forward_vertex = world_vertex + vec3(0.0, 0.0, vertex_step.z);
	right_vertex.y = get_vertex_height(right_vertex);
	forward_vertex.y = get_vertex_height(forward_vertex);
	
	vec3 right_vector = right_vertex - world_vertex;
	vec3 forward_vector = forward_vertex - world_vertex;
	
	vec3 normal = normalize(cross(forward_vector, right_vector));
	vec3 world_normal = get_world_vertex(normal, model_matrix);
	//world_normal = normal + model_matrix[3].xyz;
	world_normal -= model_matrix[3].xyz;
	
	return world_normal;
}

void vertex() {
	vec3 world_vertex = get_world_vertex_with_height(VERTEX, MODEL_MATRIX);
	NORMAL = get_vertex_normal(world_vertex, MODEL_MATRIX);
	VERTEX.y = world_vertex.y;
	UV = world_vertex.xz / vec2(textureSize(heightmap, 0)) + heightmap_uv_offset;
}

void fragment() {
	ALBEDO = texture(main_texture, UV * main_texture_tiling).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
