extends Node
var _timestamp #for logging
#onready var window_vlog = $World/Player/UIWrapper/Vehicle/MM/Sideboard/Viewport/VLog
func reparent(child: Node, new_parent: Node):
	var old_parent = child.get_parent()
	if old_parent != new_parent:
		old_parent.remove_child(child)
		new_parent.add_child(child)

func get_time_f():
	_timestamp = OS.get_time()
	return String(_timestamp.hour)+":"+String(_timestamp.minute)+":"+String(_timestamp.second)

func clog(type_string, message): # Console/Custom print/log
	print(type_string+" | "+message)
	
func clog_t(type_string, message): # Console/Custom print/log
	print(type_string+" ["+get_time_f()+"] | "+message)
	
func vlog(type_string, message): # Visual (Ingame Debug) print/log 
#	window_vlog.text += type_string+" ["+get_time_f()+"] | "+message
	pass
func alog(): # Alert (Ingame for Users) print/log
	pass
func olog(): # Overlay (Intrusive) print/log
	pass
