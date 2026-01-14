@tool
extends Node
class_name LevelChunkEntry

## The main level chunk tilemap to draw onto the level
@export var foreground_tilemap: TileMapLayer

## An optional decore tilemap to draw onto the decoration tilemap
@export var decor_tilemap: TileMapLayer


func generate_level_chunk() -> LevelChunk:
	# Set up the tilemap patterns
	var fg: TileMapPattern = foreground_tilemap.get_pattern(foreground_tilemap.get_used_cells())
	var fg_origin: Vector2i = foreground_tilemap.get_used_cells().min()	# Gets the upper-leftmost vector
	var lc: LevelChunk = LevelChunk.new(fg)
	if decor_tilemap:
		lc.decor_pattern = decor_tilemap.get_pattern(decor_tilemap.get_used_cells())
	
	# Set up the entities
	for c: Node2D in get_children():
		if _is_in_observed_group(c):
			var ps: PackedScene = PackedScene.new()
			var result: Error = ps.pack(c)
			var offset: Vector2 = Vector2(fg_origin * foreground_tilemap.tile_set.tile_size)
			if result == OK:
				lc.entities[c.global_position - offset] = ps
	
	return lc

func _is_in_observed_group(n: Node) -> bool:
	return LevelChunk.ENTITY_GROUPS.any(func(g): return n.is_in_group(g))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if get_parent() is not ChunkGrid:
		warnings.append("LevelChunkEntry node must be a child of ChunkGrid!")
	if !foreground_tilemap:
		warnings.append("Foreground tilemap must be set!")
	return []
