
const class_item = preload("./item.gd")

signal updated()

var capacity : int = 2:
	get:
		return capacity
var item : class_item = null:
	get:
		return item
var item_count : int = 0:
	get:
		return item_count


func has_item() -> bool:
	return item != null


func can_put_item(item : class_item):
	return not has_item() or \
		self.item.id == item.id && \
		not is_full()


func is_empty() -> bool:
	return item_count == 0 && has_item()


func is_full() -> bool:
	return item_count == capacity


func add_item(item : class_item, count : int = 1):
	#if item.is_stackable:
		#assert(is_empty() || self.item.id == item.id)
	#else:
		#assert(is_empty())
	self.item = item
	item_count = min(capacity, item_count + count)
	updated.emit()


func add_item_with_remains(item : class_item, count : int = 1) -> int:
	var remains : int = max(0, count + item_count - capacity)
	add_item(item, count)
	return remains
