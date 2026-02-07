@abstract
extends Resource
class_name ChunkSelector

var is_initialized: bool = false

func initialize(owner: Node) -> void:
    _initialization(owner)
    is_initialized = true

func next_chunk(_params: Dictionary = {}) -> LevelChunk:
    return null

func _initialization(_owner: Node) -> void:
    pass