extends State

@export var JUMP_FORCE = 4.0 ##Upward force of jump
@export var JUMP_HELPER = 0.01 ##Upward force applied while jump is still held
@export var CROUCH_JUMP_FORCE = 2.0 ##Upward force applied while crouch-jumping

var player
var timer #Fix for player being sent back to idle state after jumping

func _ready():
	player = get_owner()

func enter(_last_state):
	player.apply_central_impulse(Vector3.UP * JUMP_FORCE * player.mass)
	timer = 0.1
	play_jump_sfx()
	
func exit():
	pass
	
func input_update(event):
	if event.is_action_pressed("crouch"):
		player.apply_central_impulse(Vector3.UP * CROUCH_JUMP_FORCE * player.mass)
		transition.emit("PlayerCrouchingState")
		
func update(delta):
	if Input.is_action_pressed("jump"):
		player.apply_central_impulse(Vector3.UP * JUMP_HELPER * player.mass)
	if player.grounded and timer < 0:
		transition.emit("PlayerIdleState")
	else:
		timer -= delta

func play_jump_sfx():
	var material = load("res://assets/material_properties/mat_default.tres")
	if player.groundcast.is_colliding():
		return
	var ground = player.groundcast.get_collider(0)
	if "physics_material_override" in ground and ground.physics_material_override is MaterialProperties:
		if ground.physics_material_override.SFX_JUMP != null:
			material = ground.physics_material_override
	player.AudioPlayer.stream = material.SFX_JUMP
	player.AudioPlayer.spatial_play()
