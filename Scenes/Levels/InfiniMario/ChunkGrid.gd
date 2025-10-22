@tool
extends Node
class_name ChunkGrid

const GRID_OFFSET: Vector2i = Vector2i(-8, -12)	# Compensation for SMBR stuff
const GRID_SIZE: Vector2i = Vector2i(16, 1)
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
			_set_grid_chunk(gp)

	
func get_chunk_at_position(gridpos: Vector2i) -> LevelChunk:
	return get_chunk_at_index(_grid_to_index(gridpos))
	
func get_chunk_at_index(index: int) -> LevelChunk:
	return _level_chunks[_grid[index]]


# TODO: Implement this good
func _on_crossed_chunks(gridpos: Vector2i, direction: Vector2i) -> void:
	#var i = _grid[_grid_to_index(new_grid)]
	#var pattern = _level_chunks[i].get_foreground_pattern()
	#foreground.set_pattern(tilemap_offset + (new_grid + Vector2i.LEFT)  * LevelChunk.TILEMAP_SIZE, pattern)
	#foreground.set_pattern(tilemap_offset + (new_grid + Vector2i.RIGHT) * LevelChunk.TILEMAP_SIZE, pattern)
	var dest = (gridpos + direction)
	var modx = posmod(dest.x, GRID_SIZE.x)
	var mody = posmod(dest.y, GRID_SIZE.y)
	var modout = Vector2i(modx, mody)
	var rand_id = randi_range(0, _level_chunks.size()-1)
	while rand_id == _grid[_grid_to_index(gridpos)]:
		rand_id = randi_range(0, _level_chunks.size()-1)
	_set_grid_chunk(modout, randi_range(0, _level_chunks.size()-1))
	pass


func _set_grid_chunk(gridpos: Vector2i, new_id: int = _grid[_grid_to_index(gridpos)]) -> void:	
	var tilepos = gridpos * LevelChunk.TILEMAP_SIZE
	var index = _grid_to_index(gridpos)
	var old_id = _grid[index]
	var old_chunk = _level_chunks[old_id]
	_clear_pattern(tilepos + GRID_OFFSET, old_chunk.get_used_cells())
	_grid[index] = new_id
	var new_chunk = _get_level_chunk(index)
	_set_pattern(tilepos + GRID_OFFSET, new_chunk.pattern)
	
	# Edge case... literally!
	var opposite_gridpos = Vector2i.ZERO
	var edgedir = Vector2i.ZERO
	var on_edge = false
	if GRID_SIZE.x > 1:
		if gridpos.x == 0: # Loop left to right
			opposite_gridpos.x = GRID_SIZE.x-1
			edgedir.x = -1
			on_edge = true
		elif gridpos.x == GRID_SIZE.x-1: # Loop right to left
			opposite_gridpos.x = 0
			edgedir.x = 1
			on_edge = true
	
	if GRID_SIZE.y > 1:
		if gridpos.y == 0: # Loop top to bottom
			opposite_gridpos.y = GRID_SIZE.y-1
			edgedir.x = -1
			on_edge = true
		elif gridpos.y == GRID_SIZE.y-1: # Loop bottom to top
			opposite_gridpos.y = 0
			edgedir.x = 1
			on_edge = true
	
	if on_edge:
		var edgepos = (gridpos + edgedir) * LevelChunk.TILEMAP_SIZE
		var opposite_edgepos = (opposite_gridpos - edgedir) * LevelChunk.TILEMAP_SIZE
		var opposite_edge_chunk = _get_level_chunk(_grid_to_index(opposite_gridpos))
		var current_edge_chunk = new_chunk
		
		# Screw it, do it the long way
		# TODO: Optimize!
		for x in range(LevelChunk.TILEMAP_SIZE.x):
			for y in range(LevelChunk.TILEMAP_SIZE.y):
				foreground.erase_cell(edgepos + GRID_OFFSET + Vector2i(x,y))
		for x in range(LevelChunk.TILEMAP_SIZE.x):
			for y in range(LevelChunk.TILEMAP_SIZE.y):
				foreground.erase_cell(opposite_edgepos + GRID_OFFSET + Vector2i(x,y))
		#_clear_pattern(edgepos + GRID_OFFSET, opposite_edge.get_used_cells())
		_set_pattern(edgepos + GRID_OFFSET, opposite_edge_chunk.pattern)
		_set_pattern(opposite_edgepos + GRID_OFFSET, current_edge_chunk.pattern)

func _set_pattern(tile_offset: Vector2i, pattern: TileMapPattern):
	foreground.set_pattern(tile_offset,  pattern)


func _clear_grid_chunk(gridpos: Vector2i) -> void:
	var tilepos = gridpos * LevelChunk.TILEMAP_SIZE
	var chunk = _get_level_chunk(_grid_to_index(gridpos))
	
	# Idk if there's a better way to do this but here.
	for c: Vector2i in chunk.pattern.get_used_cells():
		foreground.erase_cell(c + tilepos)

func _clear_pattern(tile_offset: Vector2i, used_cells: Array[Vector2i]) -> void:
	for c: Vector2i in used_cells:
		foreground.set_cell(c + tile_offset, -1, Vector2i(-1, -1))


func _on_looped_horizontal() -> void:
	pass

func _on_looped_vertical() -> void:
	pass


func _get_level_chunk(i: int) -> LevelChunk:
	return _level_chunks[_grid[i]]

func _world_to_grid(worldpos: Vector2) -> Vector2i:
	var v = Vector2i(worldpos) / LevelChunk.WORLD_SIZE
	return Vector2i(posmod(v.x, GRID_SIZE.x), posmod(v.y, GRID_SIZE.y))

func _grid_to_index(gridpos: Vector2i) -> int:
	return gridpos.y * GRID_SIZE.x + gridpos.x

func _index_to_grid(index: int) -> Vector2i:
	return Vector2i(index % GRID_SIZE.x, index / GRID_SIZE.x) * Vector2i(1, -1)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if !get_children().any(func(c): return c is TileMapChunk):
		warnings.append("This ChunkGrid has no TileMapChunk child!")
	
	return warnings
