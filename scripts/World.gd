extends Spatial
onready var nd_ui_timer = $SessTimer
onready var nd_ui_time = $"../Layout/CounterTime/SessionTime"
#onready var nd_ui_items = $Layout/Counter/ItemPicked

enum Season {Spring, Summer, Fall, Winter}
enum LevelState {RACE,LOBBY,FROZEN}

export var LAPS := 2
var CHECKPOINTS = 0
signal state_changed
signal season_changed
signal req_ui_update
signal endgame

var state = {
	"season": Season.Spring,
	"level": LevelState.RACE
}

func switch(_level_state):
	state.level = _level_state
	emit_signal("state_changed")
	
func switch_season(_season_state):
	state.season = _season_state
	emit_signal("season_changed")

func _enter_tree():
	state.season = randi() % Season.size() #choose random season

func _ready():
	CHECKPOINTS = get_node("Trigger/Checkpoint").get_child_count()
	
	nd_ui_timer.start()
#	$Player/CollBody.connect("pos_reset",self,"_on_Player_position_reset")

func _on_pickup():
	sv.player_items += 1
	emit_signal("req_ui_update")
	
func _input(event):
	if event.is_action_pressed("cht_add_time"):
		nd_ui_timer.wait_time = nd_ui_timer.time_left+15
		nd_ui_timer.stop()
		nd_ui_timer.start()

func endgame(victory):
	if victory:
		return
	print("--- GAME END ---")
	
func _process(delta):
	nd_ui_time.text = "%0.1f"%nd_ui_timer.time_left

func _on_SessTimer_timeout():
	endgame(false) # Replace with function body
	emit_signal("endgame")

func _on_Player_position_reset():
	$TerrainGenerator._ready()
