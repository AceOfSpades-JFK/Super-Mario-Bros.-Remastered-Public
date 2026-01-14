extends RefCounted
class_name LevelChunk

## Size of the tiles in pixels.
const TILE_SIZE = Vector2i(16, 16)

## Size of the foreground tilemap in tiles.
const TILEMAP_SIZE: Vector2i = Vector2i(16, 16)

## Size of the foreground tilemap in pixels
const WORLD_SIZE: Vector2i = TILEMAP_SIZE * TILE_SIZE

## Groups that contain entities (Enemies, lakitus, pipes)
const ENTITY_GROUPS = [
	"Enemies",
]

## Pattern of the foreground tilemap
var pattern: TileMapPattern		# Caches the tile pattern

## Optional pattern of the decorative tilemap
var decor_pattern: TileMapPattern

## Dictionary of all the entities placed into the level chunk.
##  This functions as a dictionary of PackedScenes indexed by its
##  position in the level chunk.
var entities: Dictionary[Vector2, PackedScene]

## Size of the level chunk in tiles
var size: Vector2i:
	get:
		return pattern.get_size()

## Size of the level chunk in chunks
var size_in_chunks: Vector2i:
	get:
		return size / LevelChunk.TILEMAP_SIZE


func _init(p: TileMapPattern) -> void:
	pattern = p

func get_used_cells() -> Array[Vector2i]:
	return pattern.get_used_cells()
