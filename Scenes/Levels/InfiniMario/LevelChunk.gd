extends RefCounted
class_name LevelChunk

class PackedEntity:
	var scene: PackedScene
	var init_position: Vector2
	var property_overrides: Dictionary

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
var entities: Array[PackedEntity]

## Size of the level chunk in tiles
var size: Vector2i:
	get:
		return pattern.get_size()

## Size of the level chunk in chunks
var size_in_chunks: Vector2i:
	get:
		return size / LevelChunk.TILEMAP_SIZE

## Offset of where the upper-leftmost should be placed
var tilemap_offset: Vector2i

## Used to determine what chunk to generate next
var chunk_selector: ChunkSelector

## Flag that signifies whether this chunk should be used at the beginning of the level
var starting_chunk: bool


func _init(p: TileMapPattern) -> void:
	pattern = p

func add_entity(position: Vector2, packed_entity: PackedScene, overrides: Dictionary = {}) -> void:
	var entry: PackedEntity = PackedEntity.new()
	entry.scene = packed_entity
	entry.init_position = position
	entry.property_overrides = overrides
	entities.append(entry)

func get_used_cells() -> Array[Vector2i]:
	return pattern.get_used_cells()

func next_chunk() -> LevelChunk:
	return chunk_selector.next_chunk()


static func posmodvf(v: Vector2, bounds: Vector2) -> Vector2:
	return Vector2(posmod(v.x, bounds.x), posmod(v.y, bounds.y))
	
static func posmodvi(v: Vector2i, bounds: Vector2i) -> Vector2i:
	return Vector2i(posmod(v.x, bounds.x), posmod(v.y, bounds.y))
