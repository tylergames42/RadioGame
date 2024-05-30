extends State

@export var SPRINT_SPEED = 10.0 ##Sprinting movement speed

var player

func _ready():
	player = get_owner()

func enter(_last_state):
	player.current_speed = SPRINT_SPEED
	
func exit():
	pass

func input_update(_event):
	if Input.is_action_just_released("sprint"):
		transition.emit("PlayerIdleState")
	if Input.is_action_just_pressed("crouch"):
		transition.emit("PlayerSlidingState")
	if Input.is_action_just_pressed("jump") and player.grounded and player.can_climb:
		transition.emit("PlayerJumpingState")

func physics_update(_delta):
	player.slopeSliding(false)
	player.stair_step_down()
	player.stair_step_up()

func update(_delta):
	player.leg_anim_player.speed_scale = player.linear_velocity.length() * 0.2
