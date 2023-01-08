extends RigidBody

export var iid = 0 #Player instance ID
var awaits_p_respawn = false
signal pos_reset

func _input(event):
	if event.is_action_pressed("ctl_player_reset"):
		#tmp = player_vb.accel_speed
		#player_vb.accel_speed = 0
		awaits_p_respawn = true


func _integrate_forces(state):
	if awaits_p_respawn == true: #DOES RESPAWN
#		set_mode(VehicleBody.MODE_STATIC)
#		$CollBody.disabled = true
		#timer.start()
#		set_physics_process(false)
#		set_process(false)
#		brake = 99999
		linear_velocity *= 0
		angular_velocity *= 0
		# BEFORE this worked by
		#state.transform = sv.wp.get_child(sv.player_w_chk[iid]).transform
		for chk in sv.w.get_node("Trigger/Checkpoint").get_children():
			if chk.index == sv.player_w_chk[iid]:
				state.transform = chk.get_child(0).global_transform #ENSURE: SpawnPoint node gets picked
				Utility.clog("I","Player i"+str(iid)+" respawned at checkpoint "+str(sv.player_w_chk[iid]))
				awaits_p_respawn = false
				return
		Utility.clog_t("ERR","Invalid respawn target")
#		emit_signal("pos_reset")
		$"root/UIWrapper/World/TerrainGenerator"._ready()
		awaits_p_respawn = false
#		if sv.player_w_chk[iid] != 0:
#		else:
#			sv.wp.get_node("Checkpoint").get_children()
		
#		set_process(true)
#		set_physics_process(true)
#		set_mode(VehicleBody.MODE_RIGID)
#		$CollBody.disabled = false
