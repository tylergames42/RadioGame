extends State

@export var SLIDE_ANIM_SPEED = 0.1 ##Time of slide animation (in seconds)
@export var CANCEL_SLIDE_SPEED = 3.0 ##IF the player's speed gets lower than this than stop sliding
@export var SLIDING_CONTROL_MULTIPLIER = 0.2

var player

func _ready():
	player = get_owner()
	
func enter(_last_state):
	player.animation_player.play("player_crouch", -1 , 1 / SLIDE_ANIM_SPEED)
	player.apply_central_impulse(player.direction * 80)
	
func exit():
	pass

func physics_update(_delta):
	player.control_multiplier = SLIDING_CONTROL_MULTIPLIER
	player.slopeSliding(true)
	if player.linear_velocity.length() < CANCEL_SLIDE_SPEED:
		transition.emit("PlayerCrouchingState")	
