extends State

@export_range(0.0, 1.0, 0.01) var SWIM_GRAV_SCALE : float = 0.01
@export var SWIM_UP_FORCE = 0.1
@export var SWIM_DOWN_FORCE = 0.04

var player

func _ready():
	player = get_owner()

func enter(_last_state):
	player.gravity_scale = SWIM_GRAV_SCALE
	
func exit():
	player.gravity_scale = 1.0
		
func physics_update(delta):
	if Input.is_action_pressed("jump"):
		player.apply_central_impulse(Vector3.UP * SWIM_UP_FORCE * player.mass)
	if Input.is_action_pressed("crouch"):
		player.apply_central_impulse(Vector3.DOWN * SWIM_DOWN_FORCE * player.mass)
