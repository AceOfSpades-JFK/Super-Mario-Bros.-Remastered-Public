extends ChunkSelector
class_name ChunkSelectorUniform

@export var level_chunk_entry: NodePath
var level_chunk: LevelChunk

func _initialization(owner: Node) -> void:
    var node = owner.get_node(level_chunk_entry)
    assert(node is LevelChunkEntry)
    #   FUCK
    var lce: LevelChunkEntry = node as LevelChunkEntry
    level_chunk = lce.level_chunk
    
func next_chunk() -> LevelChunk:
    return level_chunk