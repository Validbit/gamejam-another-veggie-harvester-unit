extends Spatial

var threads : Array

var chunks := {}
var chunks_generated := {} # Chunks that are being generated

var noise : OpenSimplexNoise
export var material : Material


func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 7.0
	noise.persistence = 0.2
	sv.player_pos_chunk[0] = get_chunk_grid_pos(sv.player[0].transform.origin)
	
	#sv.player[0]
	#sv.player_pos_chunk[0]
	
	#var chunk = Chunk.new(Vector2(0,0),noise,material)
#	add_child(chunk)
	generate_chunk([Chunk.new(sv.player_pos_chunk[0],noise,material), null])
	generate_chunks_around(sv.player_pos_chunk[0])

func _process(delta):
	sv.player_pos_chunk_prev[0] = sv.player_pos_chunk[0]
	sv.player_pos_chunk[0] = get_chunk_grid_pos(sv.player[0].vb.translation)
	if sv.player_pos_chunk_prev[0] != sv.player_pos_chunk[0]:
		generate_chunks_around(sv.player_pos_chunk[0])
		call_deferred("cleanup_chunks", sv.player_pos_chunk[0])

func generate_chunk(arr):
	var chunk = arr[0]
	var thread = arr[1]
	chunk.generate()
	call_deferred("finished_chunk_gen", thread, chunk)
	
func finished_chunk_gen(thread, chunk):
	chunks[chunk.key] = chunk
	chunks_generated.erase(chunk.key)
	chunk.create_collider()
	call_deferred("add_child",chunk)
	chunk.call_deferred("set_owner",self)
	
	if not thread:
		return
	thread.wait_to_finish()
	var index = threads.find(thread)
	if index != -1:
			threads.remove(index)

func generate_chunks_around(grid_position):
	start_generating_chunk(Vector2(grid_position.x + 1, grid_position.y + 0))
	start_generating_chunk(Vector2(grid_position.x + 1, grid_position.y + 1))
	start_generating_chunk(Vector2(grid_position.x + 1, grid_position.y - 1))
	start_generating_chunk(Vector2(grid_position.x + 0, grid_position.y + 1))
	start_generating_chunk(Vector2(grid_position.x + 0, grid_position.y - 1))
	start_generating_chunk(Vector2(grid_position.x - 1, grid_position.y + 0))
	start_generating_chunk(Vector2(grid_position.x - 1, grid_position.y - 1))
	start_generating_chunk(Vector2(grid_position.x - 1, grid_position.y + 1))

func cleanup_chunks(center_grid_position : Vector2):
	var chunks_valid = [
		"TerrainChunk_%d_%d" % [center_grid_position.x - 1, center_grid_position.y - 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x, center_grid_position.y - 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x + 1, center_grid_position.y - 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x - 1, center_grid_position.y],
		"TerrainChunk_%d_%d" % [center_grid_position.x, center_grid_position.y],
		"TerrainChunk_%d_%d" % [center_grid_position.x + 1, center_grid_position.y],
		"TerrainChunk_%d_%d" % [center_grid_position.x - 1, center_grid_position.y + 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x, center_grid_position.y + 1],
		"TerrainChunk_%d_%d" % [center_grid_position.x + 1, center_grid_position.y + 1],
	]
	var chunks_old_keys = []
	for key in chunks.keys():
		if not chunks_valid.has(key):
			chunks_old_keys.push_back(key)
	for key in chunks_old_keys:
		print("Removing "+key)
		chunks[key].queue_free()
		chunks.erase(key)

func start_generating_chunk(grid_position: Vector2):
	var chunk = Chunk.new(grid_position, noise, material)
	if not chunks.has(chunk.key) and not chunks_generated.has(chunk.key):
		var thread = Thread.new()
		chunks_generated[chunk.key] = chunk
		print("Generating "+ chunk.key)
		thread.start(self, "generate_chunk", [chunk, thread])
		threads.push_back(thread)

func get_chunk_grid_pos(position):
	var start = Vector2(position.x, position.z)
	if start.x > 0:
		start.x += sv.CHUNK_SIZE/2.0
	elif start.x < 0:
		start.x -= sv.CHUNK_SIZE/2.0
	if start.y > 0:
		start.y += sv.CHUNK_SIZE/2.0
	elif start.y < 0:
		start.y -= sv.CHUNK_SIZE/2.0

	return Vector2(
		int(start.x / sv.CHUNK_SIZE),
		int(start.y / sv.CHUNK_SIZE)
	)
