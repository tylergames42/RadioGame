extends State #WIP

@export var CLIMBING_SPEED = 12.0 ##Climbing speed
@export var CLIMBING_SLOW_SPEED = 5.0 ##Climbing speed while walk is held

var player
var speed_mult = CLIMBING_SPEED

func _ready():
	player = get_owner()

func enter(_last_state):
	player.collider.disabled = true
	player.freeze = true
	
func exit():
	player.collider.disabled = false
	player.freeze = false

func input_update(event):
	if Input.is_action_pressed("slow_walk"):
		speed_mult = CLIMBING_SLOW_SPEED
	else:
		speed_mult = CLIMBING_SPEED
		
func update(delta):
	var direction = player.head.global_transform.basis * player.input_dir.normalized()
	
	if Input.is_action_pressed("jump"):
		direction += Vector3.UP
	elif Input.is_action_pressed("crouch"):
		direction += Vector3.DOWN
	
	player.global_position += direction * speed_mult * delta
