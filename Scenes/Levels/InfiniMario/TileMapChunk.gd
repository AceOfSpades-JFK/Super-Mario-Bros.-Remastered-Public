@tool
extends TileMapLayer
class_name TileMapChunk

var chunk_pattern: TileMapPattern

var size_in_chunks: Vector2i:
	get:
		return size / LevelChunk.TILEMAP_SIZE

var size: Vector2i:
	get:
		if chunk_pattern:
			return chunk_pattern.get_size()
		return Vector2i.ZERO


func _ready() -> void:
	chunk_pattern = get_full_pattern()
	collision_enabled = false
	navigation_enabled = false
	if !Engine.is_editor_hint():
		visible = false


func generate_level_chunk() -> LevelChunk:
	var lc: LevelChunk = LevelChunk.new(chunk_pattern)
	return lc
	

func get_full_pattern() -> TileMapPattern:
	return get_pattern(get_used_cells())


func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is ChunkGrid:
		return ["TileMapChunk must be a child of a ChunkGrid!"]
	return []
