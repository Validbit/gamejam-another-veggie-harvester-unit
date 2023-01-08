extends AudioStreamPlayer

class_name AudioStreamPlayerExtended

export var pitch_regions = [1,1.1,1.2,1.3,1.4,0.9,0.8,0.7,0.6]

func play_tonal():
	pitch_scale = pitch_regions[randi() % pitch_regions.size()]
	play()
	
func _ready():
	pass
