@tool
extends TileMapLayer
class_name TileMapChunk

var chunk_pattern: TileMapPattern
var size_in_chunks: Vector2i:
	get:
		var uc = get_used_cells()
		var size = uc.max() - uc.min()
		return size / LevelChunk.TILEMAP_SIZE


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
