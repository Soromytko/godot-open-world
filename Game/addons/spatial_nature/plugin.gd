@tool
extends EditorPlugin

const plugin_name : String = "Spatial Nature"

const icon : Texture2D = preload("./icon/icon.png")
const class_plant = preload("./scripts/plant.gd")
const class_lod_variant = preload("./scripts/lod_variant.gd")
const arborist_type_name : String = "Arborist (%s)" % plugin_name
const octree_config_type_name : String = "Plant (%s)" % plugin_name
const lod_variant_type_name : String = "LodVariant (%s)" % plugin_name


func _enter_tree():
	add_custom_type(octree_config_type_name, "Resource", class_plant, icon)
	add_custom_type(lod_variant_type_name, "Resource", class_lod_variant, icon)


func _exit_tree():
	remove_custom_type(octree_config_type_name)
	remove_custom_type(lod_variant_type_name)

