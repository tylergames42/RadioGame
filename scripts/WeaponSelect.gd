extends Control

@onready var radial_menu = $RadialMenuAdvanced

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("weapon_select"):
		Global.player.view_locked = true
		Global.player.weapon_manager.input_enabled = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		show()
	if event.is_action_released("weapon_select"):
		Global.player.view_locked = false
		Global.player.weapon_manager.input_enabled = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hide()

func _on_radial_menu_advanced_slot_selected(slot, index):
	if !visible:
		return
	Global.player.weapon_manager.swap_to_weapon(slot.name)
	print(slot.name)
