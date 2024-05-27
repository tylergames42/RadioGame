extends State

@export var NOCLIP_SPEED = 12.0 ##Noclip speed
@export var NOCLIP_SLOW_SPEED = 5.0 ##Noclip speed while walk is held
@export var NOCLIP_FAST_SPEED = 22.0 ##Noclip speed while sprint is held

var player
var speed_mult = NOCLIP_SPEED

func _ready():
	player = get_owner()

func enter(_last_state):
	player.collider.disabled = true
	player.set_collision_layer_value(1, false)
	player.freeze = true
	
	player.leg_anim_player.play("idle", -1 , 1)
	
func exit():
	player.collider.disabled = false
	player.set_collision_layer_value(1, true)
	player.freeze = false

func input_update(event):
	#if event.is_action_pressed("noclip"):
		#transition.emit("PlayerIdleState")
	if event.is_action_pressed("tune_modifiy"):
		speed_mult = NOCLIP_SLOW_SPEED
	elif event.is_action_pressed("sprint"):
		speed_mult = NOCLIP_FAST_SPEED
	else:
		speed_mult = NOCLIP_SPEED
		
func update(delta):
	var direction = player.head.global_transform.basis * player.input_dir.normalized()
	
	if Input.is_action_pressed("jump"):
		direction += Vector3.UP
	elif Input.is_action_pressed("crouch"):
		direction += Vector3.DOWN
	
	player.global_position += direction * speed_mult * delta
