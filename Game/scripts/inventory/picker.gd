extends Area3D


const class_pickup_item = preload("./pickup_item.gd")

signal pickup_item_entered(pickup_item : class_pickup_item)


func _ready():
	area_entered.connect(_on_area_body_entered)
	body_entered.connect(_on_area_body_entered)


func _on_area_body_entered(body):
	if body is class_pickup_item:
		var pickup_item : class_pickup_item = body
		pickup_item_entered.emit(pickup_item)

