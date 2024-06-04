extends State

@export var CROUCH_ANIM_SPEED = 0.1 ##Time of crouch animation (in seconds)
@export var CROUCH_SPEED = 2.0 ##Crouching movement speed

var player
var wants_to_uncrouch

func _ready():
	player = get_owner()
	
func enter(last_state):
	wants_to_uncrouch = !Input.is_action_pressed("crouch")
	if last_state != "PlayerSlidingState":
		player.animation_player.play("player_crouch", -1 , 1 / CROUCH_ANIM_SPEED)
	player.current_speed = CROUCH_SPEED
	
	player.leg_anim_player.play("into_crouch", -1 , 1)
	
func exit():
	player.animation_player.play("player_uncrouch", -1 , 1 / CROUCH_ANIM_SPEED)
	player.leg_anim_player.play("outof_crouch", -1 , 1)

func input_update(_event):
	if Input.is_action_just_released("crouch"):
		wants_to_uncrouch = true

func physics_update(_delta):
	player.stair_step_up()
	player.stair_step_down()
	player.slopeSliding()

func update(_delta):
	if wants_to_uncrouch && !player.headcast.is_colliding():
		transition.emit("PlayerWalkingState")
	if player.direction.length_squared() == 0.0:
		player.physics_material_override.friction = 1
	else:
		player.physics_material_override.friction = 0
