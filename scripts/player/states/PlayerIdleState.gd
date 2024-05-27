extends State

var player

func _ready():
	player = get_owner()

func enter(_last_state):
	player.physics_material_override.friction = 1
	
	player.leg_anim_player.play("idle", -1 , 1)
	
func exit():
	player.physics_material_override.friction = 0

func input_update(event):
	if event.is_action_pressed("crouch"):
		transition.emit("PlayerCrouchingState")
	if event.is_action_pressed("jump") and player.grounded and player.can_climb:
		transition.emit("PlayerJumpingState")

func physics_update(_delta):
	player.physics_material_override.friction = 1
	player.slopeSliding(false)

func update(_delta):
	if player.direction.length_squared() != 0.0:
		transition.emit("PlayerWalkingState")
		
