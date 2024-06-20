extends Node3D
class_name WeaponBase

@export var WEAPON_NAME : String
@export_group("Animation")
@export var ANIM_TREE : AnimationTree
@export var PICKUP_ANIM : Animation
@export var DRAW_ANIM : Animation
@export var HOLSTER_ANIM : Animation

var active : bool

func pickup() -> void:
	ANIM_TREE["parameters/pickup/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	active = true
	show()

func draw() -> void:
	active = true
	show()
	
func holster() -> void:
	active = false
	hide()

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func input_update(event: InputEvent) -> void:
	if event.is_action_pressed("fire_alt"):
		if active:
			holster()
		else:
			draw()
