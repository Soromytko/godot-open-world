@tool
extends EditorPlugin

const Terrain = preload("./scripts/terrain.gd")
const icon : Texture2D = preload("./icons/icon.png")
const type_name : String = "Terrain (BaldTerrain plugin)"


func _enter_tree():
	add_custom_type(type_name, "Node3D", Terrain, icon)
	

func _exit_tree():
	remove_custom_type(type_name)

