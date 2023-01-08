extends Spatial

onready var nd_coll_ball = $CollBody
onready var nd_mesh = $CollBody/CollisionShape/Model
onready var nd_ray = $CollBody/RayCast
onready var vb = $CollBody

export var acc = 40
export var steer_angle = 21
export var steer_speed = 5
export var steer_limit = 0.75 # car doesn't turn when near (value) stopped 
export var steer_limit_tilt = 35
export var brake_speed = 0.98

var inp_speed = 0
var inp_rotation = 0
var inp_brake = 0

func _ready():
	nd_ray.add_exception(nd_coll_ball)


func _physics_process(_delta):
	
	nd_coll_ball.add_central_force(-nd_mesh.global_transform.basis.z*inp_speed)
	nd_coll_ball.add_central_force(-nd_coll_ball.linear_velocity*inp_brake*brake_speed)
	
func _process(delta):
#	if !nd_ray.is_colliding():
#		return
	inp_speed = 0
	inp_speed += Input.get_action_strength("ctl_fwd")
	inp_speed -= Input.get_action_strength("ctl_bwd")
	inp_speed *= acc
	inp_rotation = 0
	inp_rotation += Input.get_action_strength("ctl_left")
	inp_rotation -= Input.get_action_strength("ctl_right")
	inp_rotation *= deg2rad(steer_angle)
	inp_brake = Input.get_action_strength("ctl_handbrake")
	
	# mesh rotation
	if nd_coll_ball.linear_velocity.length() > steer_limit:
		var b = nd_mesh.global_transform.basis.rotated(nd_mesh.global_transform.basis.y,inp_rotation)
		nd_mesh.global_transform.basis = nd_mesh.global_transform.basis.slerp(b,steer_speed*delta)
		nd_mesh.global_transform = nd_mesh.global_transform.orthonormalized()
		
		var t = -inp_rotation*nd_coll_ball.linear_velocity.length()/steer_limit_tilt
#		nd_mesh.rotation.z = lerp(nd_mesh.rotation.z,t,10*delta)
		
	#mesh align (rotation with gound)
	var n = nd_ray.get_collision_normal()
	var xform = align_with_y(nd_mesh.global_transform.orthonormalized(), n.normalized())
	nd_mesh.global_transform.interpolate_with(xform,10*delta)
		
func align_with_y(xform, _y):
	xform.basis.y = _y
	xform.basis.x = -xform.basis.z.cross(_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

#UNUSED:
#	var mesh_offset = Vector3(0,0,0)
#	nd_mesh.transform.origin = nd_coll_ball.transform.origin + mesh_offset # aligning w/ sphere
