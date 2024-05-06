const class_destroyable = preload("./destroyable.gd")

signal destroyed(index : int)

var index : int
var bounds : AABB
var transform : Transform3D
var destroyable : class_destroyable:
	set(value):
		_on_destroyable_changed(destroyable, value)
		destroyable = value


func destroy():
	destroyable = null
	destroyed.emit(index)


func _on_destroyable_destroyed():
	destroy()


func _on_destroyable_changed(old_destroyable : class_destroyable, new_destroyable : class_destroyable):
	if old_destroyable == new_destroyable:
		return
	if old_destroyable != null:
		old_destroyable.queue_free()
		old_destroyable.destroyed.disconnect(_on_destroyable_destroyed)
	if new_destroyable != null:
		new_destroyable.destroyed.connect(_on_destroyable_destroyed)

