extends RefCounted
class_name LevelChunk

## Size of the tiles in pixels.
const TILE_SIZE = Vector2i(16, 16)

## Size of the foreground tilemap in tiles.
const TILEMAP_SIZE: Vector2i = Vector2i(16, 16)

## Size of the foreground tilemap in pixels
const WORLD_SIZE: Vector2i = TILEMAP_SIZE * TILE_SIZE

var pattern: TileMapPattern		# Caches the tile pattern

var size: Vector2i:
	get:
		return pattern.get_size()

var size_in_chunks: Vector2i:
	get:
		return size / LevelChunk.TILEMAP_SIZE


func _init(p: TileMapPattern) -> void:
	pattern = p
