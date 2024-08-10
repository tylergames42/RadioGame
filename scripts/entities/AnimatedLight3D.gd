extends Light3D

@export var FRAMES : Array[Texture2D]
@export var ANIM_SPEED : float

@onready var update_timer = Timer.new()

var current_frame : int = 0

func _ready():
	update_timer = Timer.new()
	update_timer.wait_time = ANIM_SPEED
	update_timer.autostart = true
	update_timer.timeout.connect(update_anim)
	add_child(update_timer)

func update_anim():
	light_projector = FRAMES[current_frame]
	current_frame += 1
	if current_frame > FRAMES.size() - 1:
		current_frame = 0
