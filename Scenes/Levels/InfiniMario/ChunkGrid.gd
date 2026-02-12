@tool
extends Node
class_name ChunkGrid

const GRID_OFFSET: Vector2i = Vector2i(-8, -12)	# Compensation for SMBR stuff
const GRID_SIZE: Vector2i = Vector2i(16, 1)
const MAX_TILEMAP_SIZE: Vector2i = LevelChunk.TILEMAP_SIZE * GRID_SIZE
const MAX_WORLD_SIZE: Vector2i = MAX_TILEMAP_SIZE * LevelChunk.TILE_SIZE

@export var foreground: TileMapLayer
@export var tilemap_offset: Vector2i = Vector2i.ZERO:
	set(v):
		tilemap_offset = v
		_e_update_marker()

var _level_chunks: Array[LevelChunk]
var _starting_chunks: Array[LevelChunk]

var _grid: Array[LevelChunk] = []	# Holds indices to the level chunks array
var _ready_chunks: Array[bool] = []

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
		_ready_chunks.resize(_grid.size())
		
		# Connect any signals
		get_tree().node_added.connect(_on_node_entered_tree)
		
		# Generate level chunks
		for c: LevelChunkEntry in get_children():
			_level_chunks.append(c.level_chunk)
			if c.starting_chunk:
				_starting_chunks.append(c.level_chunk)
		
		# Randomize grid
		for i in range(0, _grid.size()):
			var new_chunk: LevelChunk
			if i == 0:
				new_chunk = _starting_chunks[randi_range(0, _starting_chunks.size()-1)]
				_ready_chunks[i] = true
			else:
				new_chunk = _get_level_chunk(i-1).next_chunk()
			
			var gp = _index_to_grid(i)
			_set_chunk_tilemap(gp, new_chunk)
			_spawn_chunk_entities.call_deferred(gp)

	
func get_chunk_at_position(gridpos: Vector2i) -> LevelChunk:
	return get_chunk_at_index(_grid_to_index(gridpos))
	
func get_chunk_at_index(index: int) -> LevelChunk:
	return _level_chunks[_grid[index]]


func update_tilemap(gridpos: Vector2i, direction: Vector2i) -> void:
	# Set the current chunk's ready to update flag
	_ready_chunks[_grid_to_index(gridpos)] = true

	# Handle aspect ratio
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = viewport_size.x / viewport_size.y
	var draw_dist: int = min(ceili(aspect), floori((GRID_SIZE.x-1)/2.0))
	
	var dest = (gridpos + (direction*draw_dist))
	var modp = LevelChunk.posmodvi(dest, GRID_SIZE)

	if !_ready_chunks[_grid_to_index(modp)]: return
	
	# Clear the chunks
	_delete_chunk_entities(modp)
	_clear_chunk_tilemap(modp)
	
	# Set the new chunks
	var prev_gp = LevelChunk.posmodvi(dest-direction, GRID_SIZE)
	var new_chunk = _get_level_chunk(_grid_to_index(prev_gp)).next_chunk()	
	_set_chunk_tilemap(modp, new_chunk)
	_spawn_chunk_entities(modp)

	# Reset the chunk's ready flag
	_ready_chunks[_grid_to_index(modp)] = false


func _clear_chunk_tilemap(gridpos: Vector2i) -> void:
	# Clear all the old chunk tiles
	var tilepos = gridpos * LevelChunk.TILEMAP_SIZE + GRID_OFFSET
	var index = _grid_to_index(gridpos)
	var old_chunk = _get_level_chunk(index)
	_clear_pattern(tilepos + old_chunk.tilemap_offset, old_chunk.pattern)
	if GRID_SIZE.x > 1:
		_clear_pattern(tilepos + old_chunk.tilemap_offset + Vector2i(MAX_TILEMAP_SIZE.x, 0), old_chunk.pattern)
		_clear_pattern(tilepos + old_chunk.tilemap_offset - Vector2i(MAX_TILEMAP_SIZE.x, 0), old_chunk.pattern)
	if GRID_SIZE.y > 1:
		_clear_pattern(tilepos + old_chunk.tilemap_offset + Vector2i(0, MAX_TILEMAP_SIZE.y), old_chunk.pattern)
		_clear_pattern(tilepos + old_chunk.tilemap_offset - Vector2i(0, MAX_TILEMAP_SIZE.y), old_chunk.pattern)
	if GRID_SIZE.x > 1 && GRID_SIZE.y > 1:
		_clear_pattern(tilepos + old_chunk.tilemap_offset + MAX_TILEMAP_SIZE, old_chunk.pattern)
		_clear_pattern(tilepos + old_chunk.tilemap_offset - MAX_TILEMAP_SIZE, old_chunk.pattern)


func _set_chunk_tilemap(gridpos: Vector2i, new_chunk: LevelChunk) -> void:
	# Set the new chunk tilemap
	var tilepos = gridpos * LevelChunk.TILEMAP_SIZE + GRID_OFFSET
	var index = _grid_to_index(gridpos)
	_grid[index] = new_chunk
	_set_pattern( tilepos + new_chunk.tilemap_offset, new_chunk.pattern)
	if GRID_SIZE.x > 1:
		_set_pattern(tilepos + new_chunk.tilemap_offset + Vector2i(MAX_TILEMAP_SIZE.x, 0), new_chunk.pattern)
		_set_pattern(tilepos + new_chunk.tilemap_offset - Vector2i(MAX_TILEMAP_SIZE.x, 0), new_chunk.pattern)
	if GRID_SIZE.y > 1:
		_set_pattern(tilepos + new_chunk.tilemap_offset + Vector2i(0, MAX_TILEMAP_SIZE.y), new_chunk.pattern)
		_set_pattern(tilepos + new_chunk.tilemap_offset - Vector2i(0, MAX_TILEMAP_SIZE.y), new_chunk.pattern)
	if GRID_SIZE.x > 1 && GRID_SIZE.y > 1:
		_set_pattern(tilepos + new_chunk.tilemap_offset + MAX_TILEMAP_SIZE, new_chunk.pattern)
		_set_pattern(tilepos + new_chunk.tilemap_offset - MAX_TILEMAP_SIZE, new_chunk.pattern)

func _set_pattern(tile_offset: Vector2i, pattern: TileMapPattern):
	foreground.set_pattern(tile_offset,  pattern)

func _clear_pattern(tile_offset: Vector2i, pattern: TileMapPattern) -> void:
	for c: Vector2i in pattern.get_used_cells():
		foreground.set_cell(c + tile_offset, -1, Vector2i(-1, -1))


func _spawn_chunk_entities(gridpos: Vector2i) -> void:
	var tilepos = _grid_to_tile(gridpos)
	var index = _grid_to_index(gridpos)
	var new_chunk = _get_level_chunk(index)
	for packed_entity in new_chunk.entities:
		var obj: Node2D = packed_entity.scene.instantiate()
		for p in packed_entity.property_overrides.keys():
			if p != &"owner":
				obj.set(p, packed_entity.property_overrides[p])
		obj.global_position = packed_entity.init_position + Vector2(tilepos) * Vector2(LevelChunk.TILE_SIZE)
		add_child(obj)
		obj.owner = self
		obj.request_ready()

func _delete_chunk_entities(gridpos: Vector2i) -> void:
	var chunk_origin: Vector2 = _grid_to_world(gridpos)

	# For the time being, just loop through all nodes in the enemies group and delete them if they're in the rectangle
	var rect: Rect2 = Rect2(chunk_origin, LevelChunk.WORLD_SIZE)
	for g: StringName in LevelChunk.ENTITY_GROUPS:
		for n: Node2D in get_tree().get_nodes_in_group(g):
			if rect.has_point(n.global_position):
				n.queue_free()


# This might be unused
func _clear_grid_chunk(gridpos: Vector2i) -> void:
	var tilepos = gridpos * LevelChunk.TILEMAP_SIZE
	var chunk = _get_level_chunk(_grid_to_index(gridpos))
	
	# Idk if there's a better way to do this but here.
	for c: Vector2i in chunk.pattern.get_used_cells():
		foreground.erase_cell(c + tilepos)


func _on_looped_horizontal() -> void:
	pass

func _on_looped_vertical() -> void:
	pass

func _on_node_entered_tree(n: Node) -> void:
	if LevelChunk.ENTITY_GROUPS.any(func(e): return n.is_in_group(e)):
		if !n.get_children().any(func(c): return c is ChunkGridPositionWrapper):
			_add_position_wrapper_to_node(n)


func _add_position_wrapper_to_node(n: Node) -> void:
	var poswrap = ChunkGridPositionWrapper.new()
	poswrap.chunk_grid = self
	n.add_child(poswrap)


func _get_level_chunk(i: int) -> LevelChunk:
	return _grid[i]

func _world_to_grid(worldpos: Vector2) -> Vector2i:
	var v = (Vector2i(worldpos) - GRID_OFFSET*LevelChunk.TILE_SIZE) / LevelChunk.WORLD_SIZE
	return Vector2i(posmod(v.x, GRID_SIZE.x), posmod(v.y, GRID_SIZE.y))

func _grid_to_world(gridpos: Vector2i) -> Vector2:
	var v = gridpos * LevelChunk.WORLD_SIZE + GRID_OFFSET * LevelChunk.TILE_SIZE
	return v

func _grid_to_tile(gridpos: Vector2i) -> Vector2i:
	return gridpos * LevelChunk.TILEMAP_SIZE + GRID_OFFSET

func _grid_to_index(gridpos: Vector2i) -> int:
	return gridpos.y * GRID_SIZE.x + gridpos.x

func _index_to_grid(index: int) -> Vector2i:
	return Vector2i(index % GRID_SIZE.x, index / GRID_SIZE.x) * Vector2i(1, -1)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if !get_children().any(func(c): return c is LevelChunkEntry):
		warnings.append("ChunkGrid node has no LevelChunkEntry child!")
	
	return warnings
