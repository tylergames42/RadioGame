extends Node3D
class_name WeaponBase

@export var WEAPON_NAME : String
@export_group("Animation")

@onready var ANIM_TREE = $AnimationTree

var active : bool

func pickup() -> void:
	hide()
	active = true
	await get_tree().create_timer(0.4).timeout
	ANIM_TREE["parameters/StateMachine/playback"].travel("pickup")
	visible = active

func draw() -> void:
	if active:
		return
	active = true
	await get_tree().create_timer(0.2).timeout
	ANIM_TREE["parameters/StateMachine/playback"].travel("draw")
	visible = active
	
func holster() -> void:
	if !active:
		return
	active = false
	ANIM_TREE["parameters/StateMachine/playback"].travel("holster")
	await ANIM_TREE.animation_finished
	visible = active

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func input_update(event: InputEvent) -> void:
	pass
