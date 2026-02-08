extends ChunkSelector
class_name ChunkSelectorRandom

@export var chunk_selectors: Array[ChunkSelector] = []
# var level_chunks: Array[LevelChunk] = []
var rng: RandomNumberGenerator

func _initialization(owner: Node) -> void:
	rng = RandomNumberGenerator.new()
	for cs: ChunkSelector in chunk_selectors:
		cs.initialize(owner)

func next_chunk(params: Dictionary = {}) -> LevelChunk:
	assert(params.has("seed"))
	rng.seed = params["seed"]
	return chunk_selectors[rng.randi_range(0, chunk_selectors.size()-1)].next_chunk(params)
