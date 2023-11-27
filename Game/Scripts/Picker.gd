class_name Picker
extends Area3D

@onready var inventory = get_parent().get_node("Inventory")

func _on_Area_body_entered(body):
	if body is Equipment:
		inventory.add_item(body)
	elif body is Item:
		get_parent().get_node("Inventory").add_item0(body)
		body.queue_free()
	else:
		print(body)
		body.queue_free()
		
		
		
