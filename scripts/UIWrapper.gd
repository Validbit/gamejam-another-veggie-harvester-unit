extends Control
onready var nd_player_raycast_ground = $World/Player/CollBody/RayCast
#onready var nd_ui_dbg_raycast_ground = $Layout/BottomBar/Second/Debug/CollisionRay
onready var nd_ui_time = $Layout/CounterTime/SessionTime
onready var nd_ui_timer = $World/SessTimer
onready var nd_ui_items = $Layout/Counter/ItemPicked
onready var nd_ui_item_last = $Layout/CounterLastItem/Icon
onready var nd_names_items = $Layout/BottomTextBar/TextL
onready var nd_names_seasons = $Layout/BottomTextBar/TextR

var audio_m = AudioServer.get_bus_index("Music")
var audio_sfx = AudioServer.get_bus_index("SFX")

func _ready():
#	$.connect("",self)
	$LayoutSummary.visible = false
	ui_update()


func ui_update():
	nd_ui_items.text = str(sv.player_items)
	var i = 0
	for itt in nd_names_items.get_children():
		itt.text = sstr.items[i][sv.player_item_last_itid+1]
		i+= 1
	i = 0
	for itt in nd_names_seasons.get_children():
#		itt.text = sv.w.state.Season.keys()[sv.w.state.season]
		itt.text = sstr.seasons[i][sv.w.state.season]
		i+= 1
	nd_ui_item_last.texture = load("res://assets/img/2dItems/"+str(sv.player_item_last_itid+1)+".png")

func _input(event):
#	if event.is_action_pressed("game_reset"):
#		get_tree().reload_current_scene()
	if event.is_action_pressed("cfg_music"):
		AudioServer.set_bus_mute(audio_m,!AudioServer.is_bus_mute(audio_m))
	if event.is_action_pressed("cfg_sfx"):
		AudioServer.set_bus_mute(audio_sfx,!AudioServer.is_bus_mute(audio_sfx))
		
func _on_World_req_ui_update():
	ui_update() # Replace with function body.


func _on_World_endgame():
	#TODO:update LayoutSummary before freeing
	$World.queue_free()
	$Layout.queue_free()
	$LayoutSummary.visible = true # Replace with function body.
	$LayoutSummary/VBoxContainer/HBoxContainer/ItemPickedSum.text = str(sv.player_items)


func _on_AnimTimerTooltip_timeout():
	$Layout/CounterTime/Note.visible = false # Replace with function body.
