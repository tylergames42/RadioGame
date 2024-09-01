extends WeaponBase

@export var MATERIALS : Array[Material]
@export var LIGHT : Light3D

var current_mat : int = 0
var uv_scale : Vector3 = Vector3(1.0, 1.0, 1.0)
var rotating : bool = false

func _ready():
	update_material()

func input_update(event):
	if event.is_action_pressed("fire_main"):
		current_mat += 1
		if current_mat > MATERIALS.size() - 1:
			current_mat = 0
		update_material()
	if event.is_action_pressed("fire_alt"):
		current_mat -= 1
		if current_mat < 0:
			current_mat = MATERIALS.size() - 1
		update_material()
	if event.is_action_pressed("tune_up"):
		if uv_scale.x < 5.0:
			uv_scale += Vector3(0.2, 0.2, 0.2)
		update_material()
	if event.is_action_pressed("tune_down"):
		if uv_scale.x > 1.0:
			uv_scale -= Vector3(0.2, 0.2, 0.2)
		update_material()
	if event.is_action_pressed("flashlight"):
		if LIGHT.visible:
			LIGHT.hide()
		else:
			LIGHT.show()
	if event.is_action_pressed("reload"):
		if rotating:
			ANIM_TREE["parameters/StateMachine/playback"].travel("RESET")
			rotating = false
		else:
			ANIM_TREE["parameters/StateMachine/playback"].travel("rotate")
			rotating = true
			
func update_material() -> void :
	for child in get_children():
		if child is CSGShape3D:
			if "uv1_scale" in MATERIALS[current_mat]:
				MATERIALS[current_mat].uv1_scale = uv_scale
			child.material_override = MATERIALS[current_mat]
