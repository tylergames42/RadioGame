extends WeaponBase

@export var LIGHT_MAIN : Light3D
@export var LIGHT_BOUNCE : Light3D
@export var ANGLE_MAX : float = 60.0
@export var ANGLE_MIN : float = 15.0

var is_toggled : bool = false
var desired_focus : float = 0.5
var focus : float = 0.5

func _ready():
	toggle_light(false)

func input_update(event):
	if event.is_action_pressed("fire_main"):
		if is_toggled:
			toggle_light(false)
		else:
			toggle_light(true)
	if event.is_action_pressed("tune_up"):
		print(desired_focus)
		if is_toggled:
			if desired_focus < 1.0:
				desired_focus += 0.05
	if event.is_action_pressed("tune_down"):
		print(desired_focus)
		if is_toggled:
			if desired_focus > 0.0:
				desired_focus -= 0.05
			
func update(delta):
	focus = lerpf(focus, desired_focus, delta)
	var energy = remap(focus, 0.0, 1.0, 4.0, 0.8)
	LIGHT_MAIN.light_energy = energy
	LIGHT_BOUNCE.light_energy = energy * 0.2
	LIGHT_MAIN.spot_angle = (focus + 0.4) * 35.0
	#LIGHT_BOUNCE.spot_angle = (focus + 0.8) * 70.0
	LIGHT_MAIN.spot_range = (energy + 0.2) * 20.0
	
			
func toggle_light(toggled : bool):
	LIGHT_MAIN.visible = toggled
	LIGHT_BOUNCE.visible = toggled
	is_toggled = toggled
