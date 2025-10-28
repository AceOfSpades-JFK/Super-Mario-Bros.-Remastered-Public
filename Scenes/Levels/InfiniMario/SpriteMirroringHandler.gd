extends Node
class_name SpriteMirroringHandler

const BORDER_ORIGIN = Vector2(0,0)
const BORDER_SIZE = Vector2(128, 128)
const BORDER_RECT = Rect2(BORDER_ORIGIN - BORDER_SIZE / 2, BORDER_SIZE)

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
		
		# for spr: Node2D in _sprite_collection:
		# 	# Create the mirror
		# 	var top_cv = spr.get_canvas_item()
		# 	add_repeats.call(top_cv, 128)

func _process(delta: float) -> void:
	# Setup viewport rect
	# var viewport_pos: Vector2 = get_viewport().get_camera_2d().position
	# var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	# if get_viewport().get_camera_2d().anchor_mode == Camera2D.AnchorMode.ANCHOR_MODE_DRAG_CENTER:
	# 	viewport_pos = get_viewport().get_camera_2d().position - (viewport_size / 2.0)
	# var viewport: Rect2 = Rect2(viewport_pos, viewport_size)
	
	for spr: Node2D in _sprite_collection:
		var cv_item: RID = spr.get_canvas_item()
		if spr.global_position.x < BORDER_ORIGIN.x:
			RenderingServer.canvas_set_item_repeat(cv_item, Vector2(BORDER_SIZE.x, 0), 1)
		else:
			RenderingServer.canvas_set_item_repeat(cv_item, Vector2(-BORDER_SIZE.x, 0), 1)


func _on_scene_tree_node_added(n: Node) -> void:
	pass

func _on_scene_tree_node_removed(n: Node) -> void:
	pass
