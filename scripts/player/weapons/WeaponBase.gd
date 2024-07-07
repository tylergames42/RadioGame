extends Node3D
class_name WeaponBase

@export var WEAPON_NAME : String
@export_group("Animation")

@onready var ANIM_TREE = $AnimationTree

var active : bool

func pickup() -> void:
	show()
	active = true
	visible = active

func draw() -> void:
	if active:
		return
	active = true
	visible = active
	for child in get_children(): #Workaround because UI shit doesn't want to hide for some reason
		if child is Control:
			child.show()
	ANIM_TREE["parameters/StateMachine/playback"].travel("draw")
	
func holster() -> void:
	if !active:
		return
	active = false
	for child in get_children(): #Workaround because UI shit doesn't want to hide for some reason
		if child is Control:
			child.hide()
	ANIM_TREE["parameters/StateMachine/playback"].travel("holster")
	await ANIM_TREE.animation_finished
	visible = active

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func input_update(event: InputEvent) -> void:
	pass
