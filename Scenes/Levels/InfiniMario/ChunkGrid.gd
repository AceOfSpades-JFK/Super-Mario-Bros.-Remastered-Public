@tool
extends Node
class_name ChunkGrid

const GRID_OFFSET: Vector2i = Vector2i(-8, -12)	# Compensation
const GRID_SIZE: Vector2i = Vector2i(4, 1)
const MAX_TILEMAP_SIZE: Vector2i = LevelChunk.TILEMAP_SIZE * GRID_SIZE
const MAX_WORLD_SIZE: Vector2i = MAX_TILEMAP_SIZE * LevelChunk.TILE_SIZE

@export var foreground: TileMapLayer
@export var view_anchor: ChunkGridViewAnchor
@export var tilemap_offset: Vector2i = Vector2i.ZERO:
	set(v):
		tilemap_offset = v
		_e_update_marker()

var _level_chunks: Array[LevelChunk]

var _grid: Array[int] = []	# Holds indices to the level chunks array

var _e_marker: Marker2D = Marker2D.new()


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		add_child(_e_marker)
		_e_update_marker()

func _e_update_marker() -> void:
	if Engine.is_editor_hint():
		_e_marker.position = tilemap_offset * LevelChunk.TILE_SIZE


func _ready() -> void:
	if !Engine.is_editor_hint():
		_grid.resize(GRID_SIZE.x * GRID_SIZE.y)
		view_anchor.crossed_chunks.connect(_on_crossed_chunks)
		view_anchor.looped_horizontal.connect(_on_looped_horizontal)
		view_anchor.looped_vertical.connect(_on_looped_vertical)
		
		# Generate level chunks
		for c: TileMapChunk in get_children():
			_level_chunks.append(c.generate_level_chunk())
		
		# Randomize grid
		for i in range(GRID_SIZE.x):
			_grid[i] = randi_range(0,  _level_chunks.size()-1)
			var gp = _index_to_grid(i)
			var ch = get_chunk_at_index(i)
			_set_grid_cell_pattern(gp, ch.pattern)

	
func get_chunk_at_position(gridpos: Vector2i) -> LevelChunk:
	return get_chunk_at_index(_grid_to_index(gridpos))
	
func get_chunk_at_index(index: int) -> LevelChunk:
	return _level_chunks[_grid[index]]


# TODO: Implement this good
func _on_crossed_chunks(new_grid: Vector2i) -> void:
	#var i = _grid[_grid_to_index(new_grid)]
	#var pattern = _level_chunks[i].get_foreground_pattern()
	#foreground.set_pattern(tilemap_offset + (new_grid + Vector2i.LEFT)  * LevelChunk.TILEMAP_SIZE, pattern)
	#foreground.set_pattern(tilemap_offset + (new_grid + Vector2i.RIGHT) * LevelChunk.TILEMAP_SIZE, pattern)
	pass


func _get_level_chunk(i: int) -> LevelChunk:
	return _level_chunks[_grid[i]]


func _set_grid_cell_pattern(gridpos: Vector2i, pattern: TileMapPattern) -> void:	
	var tilepos = gridpos * LevelChunk.TILEMAP_SIZE
	foreground.set_pattern(tilepos + GRID_OFFSET, pattern)
	pass

func _on_looped_horizontal() -> void:
	pass

func _on_looped_vertical() -> void:
	pass


func _world_to_grid(worldpos: Vector2) -> Vector2i:
	var v = Vector2i(worldpos) / LevelChunk.WORLD_SIZE
	return Vector2i(posmod(v.x, GRID_SIZE.x), posmod(v.y, GRID_SIZE.y))

func _grid_to_index(gridpos: Vector2i) -> int:
	return gridpos.y * GRID_SIZE.x + gridpos.x

func _index_to_grid(index: int) -> Vector2i:
	return Vector2i(index % GRID_SIZE.x, index / GRID_SIZE.x) * Vector2i(1, -1)
