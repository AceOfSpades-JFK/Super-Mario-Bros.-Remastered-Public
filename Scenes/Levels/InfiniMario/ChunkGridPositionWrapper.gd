extends Node
class_name ChunkGridPositionWrapper

var _parent: Node2D:
	get:
		return get_parent()

var position: Vector2:
	get:
		return _parent.position

@export var chunk_grid: ChunkGrid

signal looped_horizontal
signal looped_vertical

func _physics_process(_delta: float) -> void:
	var offset: Vector2 = ChunkGrid.GRID_OFFSET * LevelChunk.TILE_SIZE
	var size = ChunkGrid.MAX_WORLD_SIZE
	var modx: float = fposmod(position.x - offset.x, size.x)
	var mody: float = fposmod(position.y - offset.y, size.y)
	var modp: Vector2i = Vector2i(modx, mody)

	# Do a modulo thing with the position
	if Vector2i(position-offset) != modp:
		_wrap(modx, mody, Rect2(offset, size))

func _wrap(modx: float, mody: float, rect: Rect2) -> void:
	# print("Wrap")
	if position.x != modx:
		looped_horizontal.emit()
	if position.y != mody:
		looped_vertical.emit()
		
	if _parent is Player:
		_parent.wrap_player(rect)
	else:
		_parent.position = Vector2(modx, mody) + rect.position
		_parent.reset_physics_interpolation()
