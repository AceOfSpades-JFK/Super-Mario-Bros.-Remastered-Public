extends ChunkSelector
class_name ChunkSelectorRandom

@export var level_chunk_entries: Array[NodePath] = []
var level_chunks: Array[LevelChunk] = []
var rng: RandomNumberGenerator

func _initialization(owner: Node) -> void:
	rng = RandomNumberGenerator.new()
	for np: NodePath in level_chunk_entries:
		var node = owner.get_node(np)
		assert(node is LevelChunkEntry)
		#   FUCK
		var lce: LevelChunkEntry = node as LevelChunkEntry
		level_chunks.append(lce.level_chunk)

func next_chunk(params: Dictionary = {}) -> LevelChunk:
	assert(params.has("seed"))
	rng.seed = params["seed"]
	return level_chunks[rng.randi_range(0, level_chunks.size()-1)]
