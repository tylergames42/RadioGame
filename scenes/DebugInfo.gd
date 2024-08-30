extends Label

@onready var player = get_owner()
@onready var state = ""

func _ready():
	Global.debug_gui = self

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	var gnd = player.grounded
	var can_climb = player.can_climb
	var height = player.collider.shape.height
	var cur_vel = player.linear_velocity
	var dir = player.direction
	var held = player.held_object
	var freq = Global.frequency
	var strength = Global.signal_strength
		
	
	text = "FPS: " + str(fps) + "\n\nGrounded: " + str(gnd) + "\nCan Climb: " + str(can_climb) + "\nState: " + str(state) + "\nHeight: " + str(height)
	text += "\nSpeed: " + str(cur_vel.length()) + "m/s" + "\nVelocity: " + str(cur_vel) + "\nDirection: " + str(dir)  + "\nHeld Object: " + str(held)
	
	text += "\n\nFrequency: " + str(freq) + "\nSignal Strength: " + str(strength)
