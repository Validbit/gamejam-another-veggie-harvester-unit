extends Area

class_name Checkpoint

export(int) var index = 0
var player_iid = 0

func _ready():
	connect("body_entered", self, "_on_body_entered")
	
	
func _on_body_entered(body):
	player_iid = sv.chk_is_car(body)
	if player_iid != 0:
		sv.ach_checkpoint(player_iid-1,index)
