@tool
extends Node
class_name LevelChunkEntry

## The main level chunk tilemap to draw onto the level
@export var foreground_tilemap: TileMapLayer:
	set(v):
		foreground_tilemap = v
		update_configuration_warnings()

## An optional decore tilemap to draw onto the decoration tilemap
@export var decor_tilemap: TileMapLayer

## The actual instance of LevelChunk data. Created upon entering the tree
var level_chunk: LevelChunk


func _enter_tree() -> void:
	if level_chunk || Engine.is_editor_hint(): return	# Skip if editor or the LevelChunk is already generated
	
	assert(get_parent() is ChunkGrid)
	assert(foreground_tilemap)
	
	# Set up the tilemap patterns
	var used_cells := foreground_tilemap.get_used_cells()
	var fg: TileMapPattern = foreground_tilemap.get_pattern(used_cells)

	# Get the upper leftmost tile 
	var minv: Vector2i = Vector2i(2000000000, 2000000000)	# I can't remember the exact number
	for i in range(used_cells.size()):
		minv.x = min(used_cells[i].x, minv.x)
		minv.y = min(used_cells[i].y, minv.y)
	var fg_origin: Vector2i = minv
	print(fg_origin)

	# Create the Level Chunk
	var lc: LevelChunk = LevelChunk.new(fg)
	lc.tilemap_offset.x = posmod(fg_origin.x, LevelChunk.TILEMAP_SIZE.x)
	lc.tilemap_offset.y = posmod(fg_origin.y, LevelChunk.TILEMAP_SIZE.y)
	if decor_tilemap:
		lc.decor_pattern = decor_tilemap.get_pattern(decor_tilemap.get_used_cells())
	
	# Set up the entities
	for c: Node in get_children():
		if _is_in_observed_group(c):
			var ps: PackedScene = PackedScene.new()
			var result: Error = ps.pack(c)
			var pos: Vector2 = Vector2(posmod(c.global_position.x, LevelChunk.WORLD_SIZE.x), posmod(c.global_position.y, LevelChunk.WORLD_SIZE.y))
			if c.scene_file_path:
				var base_ps: PackedScene = load(c.scene_file_path)
				var dic: Dictionary = {}
				for p in c.get_property_list().map(func(e): return e.name):
					dic[p] = c.get(p)
				lc.add_entity(pos, base_ps, dic)
			else:
				if result == OK:
					#lc.entities[c.global_position - offset] = ps
					lc.add_entity(pos, ps)
		c.queue_free()
	
	level_chunk = lc

func get_level_chunks() -> Array[LevelChunk]:
	return [level_chunk]

func _compare_scene_state_string(sta: SceneState, stb: SceneState) -> String:
	var string: String = ""

	assert(sta.get_node_count() == stb.get_node_count())
	for n in range(sta.get_node_count()):
		string += str("%s:%s\n" % [sta.get_node_property_count(n), stb.get_node_property_count(n)])
		for npa in range(min(sta.get_node_property_count(n), stb.get_node_property_count(n))):
			var npb: int = npa
			while npb < stb.get_node_property_count(n)-1 && sta.get_node_property_name(n, npa) != stb.get_node_property_name(n, npb):
				npb += 1
			var va = str(sta.get_node_property_value(n, npa))
			var vb = str(stb.get_node_property_value(n, npb))
			if va != vb:
				string += "-----------------\n"
				string += str("[%s] %s: %s\n" % [sta.get_node_name(n), sta.get_node_property_name(n, npa), str(sta.get_node_property_value(n, npa))])
				string += "is not equal to\n"
				string += str("[%s] %s: %s\n" % [stb.get_node_name(n), stb.get_node_property_name(n, npb), str(stb.get_node_property_value(n, npb))])
		string += "============================\n"
	return string

func _get_scene_state_string(st: SceneState) -> String:
	var string: String
	for n in range(st.get_node_count()):
		for np in range(st.get_node_property_count(n)):
			string += str("[%s] %s: %s\n" % [st.get_node_name(n), st.get_node_property_name(n, np), str(st.get_node_property_value(n, np))])
	return string

func _is_in_observed_group(n: Node) -> bool:
	return LevelChunk.ENTITY_GROUPS.any(func(g): return n.is_in_group(g))


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if get_parent() is not ChunkGrid:
		warnings.append("LevelChunkEntry node must be a child of ChunkGrid!")
	if !foreground_tilemap:
		warnings.append("Foreground tilemap must be set!")
	return []
