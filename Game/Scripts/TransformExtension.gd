class_name TransformExtension
extends Node

static func reparent(child: Node, new_parent: Node):
	var old_parent = child.get_parent()
	if old_parent != new_parent:
		old_parent.remove_child(child)
		new_parent.add_child(child)
