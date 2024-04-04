@tool
extends EditorPlugin


const icon : Texture2D = preload("./resources/icons/icon.png")
const class_slot_based_container = preload("./scripts/slot_based_container.gd")
const class_slot_based_container_ui = preload("./scripts/slot_based_container_ui.gd")
const container_type_name : String = "SlotBasedContainer"
const container_ui_type_name : String = "SlotBasedContainerUI"


func _enter_tree():
	add_custom_type(container_type_name, "Node", class_slot_based_container, icon)
	add_custom_type(container_ui_type_name, "Control", class_slot_based_container_ui, icon)


func _exit_tree():
	remove_custom_type(container_type_name)
	remove_custom_type(container_ui_type_name)

