@icon("res://assets/ui/editor/icons/door.svg")
class_name DoorHinged
extends RigidBody3D

@export var ANIMATION_PLAYER : AnimationPlayer

@export_enum("X:0","Y:1","Z:2") var AXIS = 1
@export_enum("Both Ways:2", "Outwards:0", "Inwards:1") var OPEN_DIRECTION = 2 ##The direction the door should be able to open
@export var LOCKED : bool = false ##If the door should start locked or not
@export_range(-90, 90, 1) var STARTING_ANGLE : float = 0.0 ##The angle the door starts at
@export_range(0.0, 5.0, 0.1) var LATCH_STRENGTH : float = 1.5 ##Determines if the latch will catch the door depending on it's speed while closing. A door with a latch strength of zero will never close. (this is a totally intentional feature and not a fix for a bug)
@export_range(1, 100, 1) var OPEN_STRENGTH : float = 20.0 ##The strength of the force applied to the door when opened

@export_group("Audio")
@export var OPEN_SOUND : AudioStream
@export var CLOSE_SOUND : AudioStream
@export var LOCKED_SOUND : AudioStream

@onready var AudioPlayer = AudioStreamPlayer3D.new() #Create new 3D Audio Player for door sounds
@onready var angle_offset : float = rotation_degrees[AXIS]
@onready var hinge_global_transform: Transform3D

var is_open : bool
var can_latch : bool = true

func _ready():
	hinge_global_transform = global_transform
	rotation[AXIS] += STARTING_ANGLE
	get_meta("InteractableComponent").LOCKED = LOCKED
	
	add_child(AudioPlayer)
	if abs(get_angle()) < LATCH_STRENGTH:
		freeze = true
		is_open = false
	else:
		freeze = false
		is_open = true

func _integrate_forces(_state):
	if abs(get_angle()) < LATCH_STRENGTH and can_latch:
			close()
	else:
		can_latch = true

func open(side : bool):
	var impulse_vector = Vector3.ZERO
	
	freeze = false
	AudioPlayer.stream = OPEN_SOUND
	AudioPlayer.play()
	impulse_vector[AXIS] = OPEN_STRENGTH
	if side:
		impulse_vector[AXIS] *= -1
	can_latch = false
	is_open = true
	ANIMATION_PLAYER.play("door_open")
	
	apply_torque_impulse(impulse_vector)
	
func close():
	freeze = true
	rotation_degrees[AXIS] = angle_offset
	AudioPlayer.stream = CLOSE_SOUND
	AudioPlayer.play()
	is_open = false
	ANIMATION_PLAYER.play("door_close")

func get_angle(): # ngl idk what the fuck half this shit is doing, I just ended up using chatgpt
	var door_global_rotation = global_transform.basis
	var hinge_global_rotation_inv = hinge_global_transform.basis.inverse()
	var local_rot = door_global_rotation * hinge_global_rotation_inv
	var angle = local_rot.get_euler()[AXIS]
	return rad_to_deg(angle)

func _on_interactable_component_interacted(interactor):
	var impulse_vector = Vector3.ZERO
	if is_open:
		angular_velocity = Vector3.ZERO
		if (get_angle()) > 0:
			impulse_vector[AXIS] = -OPEN_STRENGTH
		else:
			impulse_vector[AXIS] = OPEN_STRENGTH
	else:
		if OPEN_DIRECTION == 2:
			var direction_vector = interactor.global_position - global_position
			var door_forward = global_transform.basis.z.normalized()
			var side = door_forward.dot(direction_vector.normalized())
			if side > 0:
				open(true)
			else:
				open(false)
		else:
			open(OPEN_DIRECTION)
	apply_torque_impulse(impulse_vector)

func _on_interactable_component_interacted_locked(_interactor):
	AudioPlayer.stream = LOCKED_SOUND
	AudioPlayer.play()
	ANIMATION_PLAYER.play("door_locked", -1, 1.4)
