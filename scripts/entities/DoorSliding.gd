@icon("res://assets/ui/editor/icons/door.svg")
class_name DoorSliding
extends RigidBody3D

@export var ANIMATION_PLAYER : AnimationPlayer
@onready var JOINT = $SliderJoint3D
@export_range(1, 100, 1) var OPEN_STRENGTH : float = 25.0 ##The strength of the force applied to the door when opened

@export_group("Audio")
@export var OPEN_SOUND : AudioStream
@export var CLOSE_SOUND : AudioStream
@export var LOCKED_SOUND : AudioStream

@onready var AudioPlayer = SpatialAudioPlayer3D.new() #Create new 3D Audio Player for door sounds
@onready var closed_pos = JOINT.global_position
@onready var open_dir = JOINT.global_transform.basis.x
@onready var close_dir = -JOINT.global_transform.basis.x

var is_open : bool
var can_latch : bool = true

func _ready():
	add_child(AudioPlayer)
	if (global_position.distance_to(closed_pos) <= 0.04):
		freeze = true
		can_latch = false
		is_open = false
	else:
		freeze = false
		can_latch = false
		is_open = true

func _integrate_forces(_state):
	if (global_position.distance_to(closed_pos) <= 0.04):
		if can_latch:
			latch()
	else:
		can_latch = true

func open():
	var impulse_vector = open_dir * OPEN_STRENGTH
	freeze = false
	AudioPlayer.stream = OPEN_SOUND
	AudioPlayer.spatial_play()
	can_latch = false
	is_open = true
	#ANIMATION_PLAYER.play("door_open")
	
	apply_central_impulse(impulse_vector)
	
func latch():
	freeze = true
	AudioPlayer.stream = CLOSE_SOUND
	AudioPlayer.spatial_play()
	is_open = false
	#ANIMATION_PLAYER.play("door_close")
	
func close():
	var impulse_vector = close_dir * OPEN_STRENGTH
	linear_velocity *= 0.0
	apply_central_impulse(impulse_vector)

func _on_interactable_component_interacted(interactor):
	if is_open:
		close()
	else:
		open()

func _on_interactable_component_interacted_locked(_interactor):
	AudioPlayer.stream = LOCKED_SOUND
	AudioPlayer.spatial_play()
	#ANIMATION_PLAYER.play("door_locked", -1, 1.4)
