@tool
extends Node
class_name LevelChunkEntry

## The main level chunk tilemap to draw onto the level
@export var foreground_tilemap: TileMapLayer:
	set(v):
		foreground_tilemap = v
		update_configuration_warnings()

## An optional decore tilemap to draw onto the decoration tilemap
@export var decor_tilemap: TileMapLayer

## The actual instance of LevelChunk data. Created upon entering the tree
var level_chunk: LevelChunk


func _enter_tree() -> void:
	if level_chunk || Engine.is_editor_hint(): return	# Skip if editor or the LevelChunk is already generated
	
	assert(get_parent() is ChunkGrid)
	assert(foreground_tilemap)
	
	# Set up the tilemap patterns
	var fg: TileMapPattern = foreground_tilemap.get_pattern(foreground_tilemap.get_used_cells())
	var fg_origin: Vector2i = foreground_tilemap.get_used_cells().min()	# Gets the upper-leftmost vector
	var lc: LevelChunk = LevelChunk.new(fg)
	if decor_tilemap:
		lc.decor_pattern = decor_tilemap.get_pattern(decor_tilemap.get_used_cells())
	
	# Set up the entities
	for c: Node in get_children():
		if _is_in_observed_group(c):
			var ps: PackedScene = PackedScene.new()
			var result: Error = ps.pack(c)
			var offset: Vector2 = Vector2(fg_origin * foreground_tilemap.tile_set.tile_size)
			if c.scene_file_path:
				var base_ps: PackedScene = load(c.scene_file_path)
				var dic: Dictionary = {}
				for p in c.get_property_list().map(func(e): return e.name):
					dic[p] = c.get(p)
				lc.add_entity(c.global_position - offset, base_ps, dic)
			else:
				if result == OK:
					#lc.entities[c.global_position - offset] = ps
					lc.add_entity(c.global_position - offset, ps)
		c.queue_free()
	
	level_chunk = lc

func _is_in_observed_group(n: Node) -> bool:
	return LevelChunk.ENTITY_GROUPS.any(func(g): return n.is_in_group(g))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if get_parent() is not ChunkGrid:
		warnings.append("LevelChunkEntry node must be a child of ChunkGrid!")
	if !foreground_tilemap:
		warnings.append("Foreground tilemap must be set!")
	return []
