extends State

@export var WALK_SPEED = 7.0 ##Walking movement speed

var player

func _ready():
	player = get_owner()

func enter(_last_state):
	player.current_speed = WALK_SPEED
	
	player.leg_anim_player.play("walk", -1 , 1)
	
func exit():
	pass

func input_update(_event):
	if Input.is_action_pressed("sprint"):
		transition.emit("PlayerSprintingState")
	if Input.is_action_pressed("crouch"):
		transition.emit("PlayerCrouchingState")
	if Input.is_action_just_pressed("jump") and player.grounded and player.can_climb:
		transition.emit("PlayerJumpingState")

func physics_update(_delta):
	player.stair_step_up()
	player.stair_step_down()
	player.slopeSliding()

func update(_delta):
	if player.direction.length_squared() == 0.0:
		transition.emit("PlayerIdleState")
		
	player.leg_anim_player.speed_scale = player.linear_velocity.length() * 0.2
