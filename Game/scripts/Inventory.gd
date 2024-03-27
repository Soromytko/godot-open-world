class_name Inventory
extends Node

@onready var hand = get_parent().get_node("Hand")
# onready var axe = get_node("/root/Spatial/Axe2")
@onready var wood_count_text = get_node("/root/Node3D/Control/WoodCount")
@onready var foliage_count_text = get_node("/root/Node3D/Control/LeafCount")

signal wood_count_changed(count)
signal foliage_count_changed(count)

var wood_count = 0
var foliage_count = 0

var items = []

func get_count_request(item : Item):
	print(item)
	if item is Wood:
		return wood_count
	elif item is Foliage:
		return foliage_count
	return 0


func remove_request(item : Item, count: int):
	if item is Wood:
		wood_count -=  count
	elif item is Foliage:
		foliage_count -= count


func _on_wood_count_changed(count):
	wood_count_text.text = str(count)
	
func _on_foliage_count_changed(count):
	foliage_count_text.text = str(count)

func _ready():
	self.connect("wood_count_changed", Callable(self, "_on_wood_count_changed"))
	self.connect("foliage_count_changed", Callable(self, "_on_foliage_count_changed"))
	

func set_parent2(parent, child):
	child.get_parent().remove_child(child)
	parent.add_child(child)
	
	
func remove_wood(count : int):
	wood_count -= count
	emit_signal("wood_count_changed", wood_count)
	
	
func remove_foliage(count : int):
	foliage_count -= count
	emit_signal("foliage_count_changed", foliage_count)
	
func add_item0(item : Item):
	items.append(item)
	if item is Wood:
		wood_count += 1
		emit_signal("wood_count_changed", wood_count)
	if item is Foliage:
		foliage_count += 1
		emit_signal("foliage_count_changed", foliage_count)
	
	
func add_item(item):
	return
#	item.get_node("CollisionShape3D").disabled = true
#	item.mode = RigidBody3D.FREEZE_MODE_STATIC
#	TransformExtension.reparent(item, hand)
#	item.rotation_degrees = Vector3.ZERO
##	item.b = true
#	item.transform.origin = Vector3.ZERO
##	item.global_transform.origin = hand.global_transform.origin



