extends Node
class_name SpriteMirroringHandler

const BORDER_ORIGIN = ChunkGrid.GRID_OFFSET
const BORDER_SIZE = ChunkGrid.MAX_WORLD_SIZE
const BORDER_RECT = Rect2(BORDER_ORIGIN, BORDER_SIZE)

@export var node_groups: Array[StringName] = []

var _sprite_collection: Array[Node2D] = []


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_scene_tree_node_added)
	get_tree().node_removed.connect(_on_scene_tree_node_removed)

#func _ready() -> void:		
	#for group in node_groups:
		#var nodes: Array[Node] = get_tree().get_nodes_in_group(group)
		#var n: Node = nodes.pop_back()
		#while n != null:
			#if n is Node2D && (n as Node2D).get_canvas_item():
				#_sprite_collection.append(n)
			#nodes.append_array(n.get_children())
			#n = nodes.pop_back()


func _process(_delta: float) -> void:	
	for spr: Node2D in _sprite_collection:
		if spr:
			var cv_item: RID = spr.get_canvas_item()
			if spr.global_position.x < BORDER_ORIGIN.x + BORDER_SIZE.x / 2:
				RenderingServer.canvas_set_item_repeat(cv_item, Vector2(BORDER_SIZE.x, 0), 1)
			else:
				RenderingServer.canvas_set_item_repeat(cv_item, Vector2(-BORDER_SIZE.x, 0), 1)


func _on_scene_tree_node_added(n: Node) -> void:
	#if node_groups.any(func(g): return n.is_in_group(g)):
	if n is Node2D && (n as Node2D).get_canvas_item():
		_sprite_collection.append(n)

func _on_scene_tree_node_removed(n: Node) -> void:
	if n is Node2D && (n as Node2D).get_canvas_item():
		if _sprite_collection.has(n):
			_sprite_collection.erase(n)
