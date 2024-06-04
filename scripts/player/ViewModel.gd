extends Node3D
class_name ViewModel

@export var VIEWBOB_AMOUNT : float = 0.0
@export var VIEWSWAY_AMOUNT : float = 0.0
@export var PLAYER : RigidBody3D

var default_pos
var default_rot
var temp = 5
@onready var head = get_parent()
var past_rot

func _ready():
	default_pos = position
	default_rot = rotation
	
func _physics_process(delta):
	rotation.y = lerp(rotation.y, -PLAYER.linear_velocity.y * 0.01, 10 * delta)
	rotation.z = lerp(rotation.x, (PLAYER.linear_velocity.x + PLAYER.linear_velocity.z) * 0.01, 10 * delta)
