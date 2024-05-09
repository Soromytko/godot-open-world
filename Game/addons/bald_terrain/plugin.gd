@tool
extends EditorPlugin

const class_terrain = preload("./scripts/terrain.gd")
const class_terrain_data = preload("./scripts/terrain_data.gd")
const icon : Texture2D = preload("./icons/icon.png")
const terrain_type_name : String = "Terrain (BaldTerrain plugin)"
const terrain_data_type_name : String = "TerrainData (BaldTerrain plugin)"


func _enter_tree():
	add_custom_type(terrain_type_name, "Node3D", class_terrain, icon)
	add_custom_type(terrain_data_type_name, "Resource", class_terrain_data, icon)
	

func _exit_tree():
	remove_custom_type(terrain_type_name)
	remove_custom_type(terrain_data_type_name)

