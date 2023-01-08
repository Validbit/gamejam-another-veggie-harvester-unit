extends MeshInstance
class_name Chunk

var pos : Vector2
var grid_pos : Vector2
var key : String
var noise : OpenSimplexNoise
var material : Material
var vtx = [] # verticies
var uv = []

var path = "res://assets/obj/pickup/"
var dir = Directory.new()
var is_pickup_dir_init = false

var pickup = preload("res://props/Pickup.tscn")
const pickup_offsets_relative = [.25,.5,.75,1,.05,.15,.35,.45,.55,.65,.85,.95,.18,.22,.28,.42,.58,.67,.72,.83,.92]
var pickup_offsets = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] # e.g. [1/4, 1/2, 3/4, 1] out of total vtx per chunk
var pickup_preloads = [""]

func _init(grid_pos : Vector2, noise : OpenSimplexNoise, material : Material):
	self.grid_pos = grid_pos
	self.pos = Vector2(
		float(grid_pos.x) * float(sv.CHUNK_SIZE) - float(sv.CHUNK_SIZE) / 2.0,
		float(grid_pos.y) * float(sv.CHUNK_SIZE) - float(sv.CHUNK_SIZE) / 2.0)
	self.key = "TerrainChunk_%d_%d" % [grid_pos.x,grid_pos.y]
	self.noise = noise
	self.material = setup_material(material)

func setup_material(material : Material):
	if material:
		return material
		
	var _material
	_material = SpatialMaterial.new()
	_material.albedo_color = Color(1.0,1.0,0.0)
	return _material

func _ready():
#	for _iv in range(0,pickup_offsets_relative.size()-1):
#		pickup_offsets[_iv].push(1)
	pass
	

func generate():
	var st = SurfaceTool.new()
	
	for x in range(sv.CHUNK_QUAD_COUNT):
		for z in range(sv.CHUNK_QUAD_COUNT):
			generate_quad(
				Vector3(pos.x + x * sv.QUAD_SIZE, 0, pos.y + z * sv.QUAD_SIZE),
				Vector2(sv.QUAD_SIZE, sv.QUAD_SIZE)
			)
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	for i in range(vtx.size()):
		st.add_uv(uv[i])
		st.add_vertex(vtx[i])
	
	st.generate_normals()
	self.set_name(key)
	self.mesh = st.commit()
	self.cast_shadow = 1
	
func generate_quad(position: Vector3, size: Vector2):
	vtx.push_back(create_vertex(position.x, position.z + size.y))
	vtx.push_back(create_vertex(position.x, position.z))
	vtx.push_back(create_vertex(position.x + size.y, position.z))
	
	vtx.push_back(create_vertex(position.x, position.z + size.y))
	vtx.push_back(create_vertex(position.x + size.x, position.z))
	vtx.push_back(create_vertex(position.x + size.x, position.z + size.y))
	
	uv.push_back(Vector2(0,0))
	uv.push_back(Vector2(0,1))
	uv.push_back(Vector2(1,1))
	
	uv.push_back(Vector2(0,0))
	uv.push_back(Vector2(1,1))
	uv.push_back(Vector2(1,0))
	
func create_collider():
	var shape = ConcavePolygonShape.new()
	shape.set_faces(PoolVector3Array(vtx))
	var collshape = CollisionShape.new()
	collshape.set_shape(shape)
	var staticbody = StaticBody.new()
	staticbody.collision_layer = 1
	staticbody.collision_mask = 2
	staticbody.add_child(collshape)
	add_child(staticbody)
	
	if !is_pickup_dir_init:
		init_pickups()
	
#	for iv in range(0,pickup_offsets_relative.size()-1,1):
#		pickup_offsets[iv] = (vtx.size()-1)*pickup_offsets_relative[iv]
#		var _pickup = pickup.instance()
#		_pickup.transform.origin = vtx[pickup_offsets[iv]]+Vector3(0,.5,0)
#		add_child(_pickup)
#		var _pickup_meshes_root = _pickup.get_child(0)
#		if _pickup_meshes_root.get_child_count() != 0:
#			for model_mesh in _pickup_meshes_root.get_children(): 
#				model_mesh.queue_free()
#		var pickup_i = randi() % pickup_preloads.size()
#		var pp = load(pickup_preloads[pickup_i]).instance()
#		_pickup_meshes_root.add_child(pp)
	var _itid
	for iv in range(0,pickup_offsets_relative.size()-1,1):
		pickup_offsets[iv] = (vtx.size()-1)*pickup_offsets_relative[iv]
		var _pickup = pickup.instance()
		_pickup.transform.origin = vtx[pickup_offsets[iv]]+Vector3(0,.5,0)
		add_child(_pickup)
		var _pickup_meshes_root = _pickup.get_child(0)
		_itid = randi() % pickup_preloads.size()
		if _pickup_meshes_root.get_child_count() != 0:
			_pickup_meshes_root.get_child(0).mesh = load(pickup_preloads[_itid])
			_pickup_meshes_root.get_child(0).mesh.surface_get_material(0).params_diffuse_mode = 4 #toon
			_pickup_meshes_root.get_child(0).mesh.surface_get_material(0).metallic = 0
			_pickup_meshes_root.get_child(0).mesh.surface_get_material(0).metallic_specular = 0
			_pickup_meshes_root.get_child(0).mesh.surface_get_material(0).roughness = 1
			_pickup.itid = _itid #itid has to be on area/BODY to be able to read it from collision
#			sv.player_item_last_itid = _itid
		else:
			break
		#TODO: translation strings (related)
func create_vertex(x,z):
	var y = noise.get_noise_2d(x,z)*3
	return Vector3(x,y,z)
	
func init_pickups():
	dir.open(path)
	dir.list_dir_begin()
	while true: # init
		var file_name = dir.get_next()
		if file_name == "":
#			#break the while loop when get_next() returns ""
			break
##		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
##			pickup_preloads.append("")#empty space for later random-access insertion
		elif file_name.ends_with(".mesh"):
			pickup_preloads.append("")
	dir.list_dir_end()
	dir.open(path)
	dir.list_dir_begin()
	while true: # loading
		var file_name = dir.get_next()
		if file_name == "":
			#break the while loop when get_next() returns ""
			break
#		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
#			#if !file_name.ends_with(".import"):
#
#			pickup_preloads[int(file_name.split(".")[0])] = path + "/" + file_name
		elif file_name.ends_with(".mesh"):
			pickup_preloads[int(file_name.split("_")[1])] = path + "/" + file_name
	dir.list_dir_end()
	pickup_preloads.pop_front()
