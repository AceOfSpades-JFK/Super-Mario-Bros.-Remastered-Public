extends Node
class_name SpriteMirroringHandler

@export var node_groups: Array[StringName] = []

var _sprite_collection: Array[Node2D] = []
var _sprite_registry: Dictionary[Node2D, Array]


func _ready() -> void:
	var add_repeats = func(cv_item: RID, length: float) -> void:
		RenderingServer.canvas_set_item_repeat(cv_item, Vector2.LEFT * length, 2)
		
	for group in node_groups:
		var nodes: Array[Node] = get_tree().get_nodes_in_group(group)
		var n: Node = nodes.pop_back()
		while n != null:
			if n is Node2D && (n as Node2D).get_canvas_item():
				_sprite_collection.append(n)
			nodes.append_array(n.get_children())
			n = nodes.pop_back()
		
		for spr: Node2D in _sprite_collection:
			# Create the mirror
			var top_cv = spr.get_canvas_item()
			add_repeats.call(top_cv, 128)


func _on_scene_tree_node_added(n: Node) -> void:
	pass

func _on_scene_tree_node_removed(n: Node) -> void:
	pass
