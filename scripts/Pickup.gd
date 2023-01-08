extends Spatial

var itid = 0

#func get_name():
#	var s = ""
#	if tr(!item_name.empty()):
#		s = tr(item_name) #space is hardcoded/written in table due to short variants (e.g. "l'" = "le ")
#	s += tr(item_name)
#	return s



func _on_Area_body_entered(body):
	print("E!")
	$"/root/UIWrapper/Audio/SFX/Pickup".play_tonal()
	sv.player_item_last_itid = itid
	$"/root/UIWrapper/World"._on_pickup()
	queue_free()
