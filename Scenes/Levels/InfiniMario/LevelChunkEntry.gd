@tool
extends Node
class_name LevelChunkEntry

## The main level chunk tilemap to draw onto the level
@export var foreground_tilemap: TileMapLayer

## An optional decore tilemap to draw onto the decoration tilemap
@export var decor_tilemap: TileMapLayer

const OBSERVED_GROUPS = [
	"Enemies",
]


func generate_level_chunk() -> LevelChunk:
	# Set up the tilemap patterns
	var fg: TileMapPattern = foreground_tilemap.get_pattern(foreground_tilemap.get_used_cells())
	var lc: LevelChunk = LevelChunk.new(fg)
	if decor_tilemap:
		lc.decor_pattern = decor_tilemap.get_pattern(decor_tilemap.get_used_cells())
	
	# Set up the objects
	for c: Node2D in get_children():
		if _is_in_observed_group(c):
			var ps: PackedScene = PackedScene.new()
			var result: Error = ps.pack(c)
			if result == OK:
				lc.objects[c.position] = ps
	
	return lc

func _is_in_observed_group(n: Node) -> bool:
	return OBSERVED_GROUPS.any(func(g): return n.is_in_group(g))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if get_parent() is not ChunkGrid:
		warnings.append("LevelChunkEntry node must be a child of ChunkGrid!")
	if !foreground_tilemap:
		warnings.append("Foreground tilemap must be set!")
	return []
