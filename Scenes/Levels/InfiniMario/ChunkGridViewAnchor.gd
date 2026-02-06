extends Node
class_name ChunkGridViewAnchor

signal looped_horizontal
signal looped_vertical

var _parent: Node2D:
	get:
		return get_parent()

var position: Vector2:
	get:
		return _parent.position

@export var chunk_grid: ChunkGrid

@onready var _prev_position: Vector2 = position


func _physics_process(_delta: float) -> void:
	# Modulo'd vectors
	var offset: Vector2 = ChunkGrid.GRID_OFFSET * LevelChunk.TILE_SIZE
	var size = ChunkGrid.MAX_WORLD_SIZE
	var modx: float = fposmod(position.x - offset.x, size.x)
	var mody: float = fposmod(position.y - offset.y, size.y)
	var modp: Vector2i = Vector2i(modx, mody)
	var gridpos = Vector2i(position-offset) / LevelChunk.WORLD_SIZE
	var prev_gridpos = Vector2i(_prev_position-offset) / LevelChunk.WORLD_SIZE
	
	# Check if the anchor has crossed chunks
	if gridpos != prev_gridpos && Vector2i(position-offset) == modp:
		# Use current position and _prev_positions. This is before the current pos gets modulo'd
		var direction = gridpos - prev_gridpos
		print("%s - %s = %s" % [gridpos, prev_gridpos, direction])
		gridpos.x = posmod(gridpos.x, ChunkGrid.GRID_SIZE.x)
		gridpos.y = posmod(gridpos.y, ChunkGrid.GRID_SIZE.y)
		_view.call_deferred(gridpos, direction)
	
	_prev_position = position

func _view(gridpos, direction) -> void:
	print("View")
	chunk_grid.update_tilemap(gridpos, direction)
