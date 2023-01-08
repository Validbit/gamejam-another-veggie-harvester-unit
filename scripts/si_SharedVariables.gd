extends Node

onready var w = $"/root/UIWrapper/World"
onready var player = [$"/root/UIWrapper/World/Player" as Spatial]

var player_rpm = [0] #4 players => p1 = 0. index
var player_spd = [0]
var player_boost = [100] # Current (remaining) amount of player's 
var player_jump_capacity_timer = [Timer.new()]
#_w_ = World-related variables - "They relate to the world itself or are important from & for narrative (perspective)"
var player_w_chk = [0] #WorldData>Checkpoints
var player_w_lap = [1]
var player_w_camera_mode = [2] #Determines behaviour of active camera

#region trackgen
var player_pos_chunk = [Vector2(0,0),Vector2.ZERO,Vector2.ZERO,Vector2.ZERO]
var player_pos_chunk_prev = [Vector2(0,0),Vector2.ZERO,Vector2.ZERO,Vector2.ZERO]

var player_items = 0
var player_item_last_itid = 0

const QUAD_SIZE := 16
const CHUNK_QUAD_COUNT := 12
const CHUNK_SIZE = QUAD_SIZE*CHUNK_QUAD_COUNT #int(QUAD_SIZE * CHUNK_QUAD_COUNT)
#endregion


func get_data_f(target,index): # ex. "player", 1
	if target=="player_rpm":
		return str("%3d" % abs(floor(player_rpm[index-1]))) #%03d for filling with zeroes
	if target=="player_spd":
		return str("%3d" % abs(floor(player_spd[index-1])))
	if target=="player_boost":
		return str("%3d" % abs(floor(player_boost[index-1])))
	else:
		Utility.clog("ERR","[SharedVariables] Invalid data request target")	

func chk_is_car(bodyinstance: Node):
	if bodyinstance is VehicleBody:
		return bodyinstance.iid+1
	return 0 #AS false

func ach_checkpoint(player_iid, checkpoint_index, is_forced = false): #Achieve Checkpoint
	if !(player_w_chk[player_iid] >= checkpoint_index) or is_forced:
		player_w_chk[player_iid] = checkpoint_index
		player[player_iid].vb.hud_bb_val1.text = "LAP "+str(player_w_lap[player_iid])+" / "+str(w.LAPS)+" ("+str(checkpoint_index)+" / "+ str(w.CHECKPOINTS-1)+")"
		print("I | You "+str(player_iid)+" have reached a new checkpoint ("+str(checkpoint_index)+")")

func _ready():
	pass
