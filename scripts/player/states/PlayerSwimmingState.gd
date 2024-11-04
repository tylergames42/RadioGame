extends State

@export_range(-2.0, 0.0, 0.01) var SWIM_GRAV : float = -0.5
@export var SWIM_UP_FORCE = 4.0
@export var SWIM_DOWN_FORCE = 2.0

var player

func _ready():
	player = get_owner()

#func enter(_last_state):
	#player.gravity_scale = SWIM_GRAV_SCALE
	#
#func exit():
	#player.gravity_scale = 1.0
		
func physics_update(delta):
	player.apply_central_impulse(Vector3.DOWN * SWIM_GRAV)
	if Input.is_action_pressed("jump"):
		player.apply_central_impulse(Vector3.UP * SWIM_UP_FORCE * player.mass * delta)
	if Input.is_action_pressed("crouch"):
		player.apply_central_impulse(Vector3.DOWN * SWIM_DOWN_FORCE * player.mass * delta)
