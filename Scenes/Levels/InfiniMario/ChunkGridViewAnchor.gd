extends Node
class_name ChunkGridViewAnchor

signal crossed_chunks(new_grid: Vector2i)
signal looped_horizontal
signal looped_vertical

var _parent: Node2D:
	get:
		return get_parent()

var position: Vector2:
	get:
		return _parent.position

@onready var _prev_position: Vector2 = position


func _physics_process(_delta: float) -> void:
	# Modulo'd vectors
	var offset: Vector2 = ChunkGrid.GRID_OFFSET * LevelChunk.TILE_SIZE
	var modx: float = fposmod(position.x - offset.x, ChunkGrid.MAX_WORLD_SIZE.x)
	var mody: float = fposmod(position.y - offset.y, ChunkGrid.MAX_WORLD_SIZE.y)
	var modp: Vector2i = Vector2i(modx, mody)
	var gridpos = Vector2i(modp) / LevelChunk.WORLD_SIZE
	var prev_gridpos = Vector2i(_prev_position) / LevelChunk.WORLD_SIZE
	
	# Check if the anchor has crossed chunks
	if gridpos != prev_gridpos:
		crossed_chunks.emit(gridpos)
	_prev_position = position
		
	# Do a modulo thing with the position
	if (position + offset).x != modx:
		looped_horizontal.emit()
	if (position + offset).y != mody:
		looped_vertical.emit()
	_parent.position = Vector2(modx, mody) + offset
