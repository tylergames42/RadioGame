extends Node3D

@export var BUTTONS : Control
@export var ANIM_TREE : AnimationTree
@export var ANIM_OPEN : Animation
@export var ANIM_CLOSE : Animation

var open : bool = false
var current_selection : String = "null"

func _ready():
	visible = open
	BUTTONS.visible = open

func _input(event):
	if event.is_action_pressed("weapon_select"):
		open_menu()
	if event.is_action_released("weapon_select"):
		close_menu()

func open_menu():
	if open:
		return
	open = true
	Global.player.weapon_manager.holster_active()
	Global.player.view_locked = true
	Global.player.weapon_manager.input_enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ANIM_TREE["parameters/OpenStateMachine/playback"].travel("open")
	show()
	BUTTONS.show()
		
func close_menu():
	if !open:
		return
	open = false
	Global.player.view_locked = false
	Global.player.weapon_manager.input_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player.weapon_manager.swap_to_weapon(current_selection)
	BUTTONS.visible = open
	ANIM_TREE["parameters/OpenStateMachine/playback"].travel("close")
	ANIM_TREE["parameters/SelectStateMachine/playback"].travel("none")
	current_selection = "null"
	await get_tree().create_timer(0.2).timeout
	visible = open

#Lots of signals, probably a better way to do this?
func _on_radio_button_pressed():
	current_selection = "radio"
	close_menu()
	
func _on_camera_button_pressed():
	current_selection = "camera"
	close_menu()

func _on_spraycan_button_pressed():
	current_selection = "spraycan"
	close_menu()

func _on_radio_button_mouse_entered():
	if open:
		ANIM_TREE["parameters/SelectStateMachine/playback"].travel("radio")
		current_selection = "radio"

func _on_radio_button_mouse_exited():
	if open:
		ANIM_TREE["parameters/SelectStateMachine/playback"].travel("none")
		current_selection = "null"

func _on_camera_button_mouse_entered():
	if open:
		ANIM_TREE["parameters/SelectStateMachine/playback"].travel("camera")
		current_selection = "camera"

func _on_camera_button_mouse_exited():
	if open:
		ANIM_TREE["parameters/SelectStateMachine/playback"].travel("none")
		current_selection = "null"
