extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.paused = false
	hide()

func _input(event):
	if event.is_action_pressed("pause"):
		if Global.paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Global.paused = false
			Global.player.weapon_manager.input_enabled = true
			hide()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Global.paused = true
			Global.player.weapon_manager.input_enabled = false
			show()
	if event.is_action_pressed("debug_menu"):
		if Global.debug_gui.visible:
			Global.debug_gui.visible = false
		else:
			Global.debug_gui.visible = true
		

func _on_reload_button_pressed() -> void:
	var _reload = get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_radio_button_pressed() -> void:
	Global.player.weapon_manager.add_weapon(load("res://scenes/weapons/WeaponRadio.tscn"))

func _on_camera_button_pressed() -> void:
	Global.player.weapon_manager.add_weapon(load("res://scenes/weapons/WeaponCamera.tscn"))
	
func _on_flashlight_button_pressed() -> void:
	Global.player.weapon_manager.add_weapon(load("res://scenes/weapons/WeaponFlashlight.tscn"))
	
func _on_mat_test_button_pressed() -> void:
	Global.player.weapon_manager.add_weapon(load("res://scenes/weapons/WeaponMatTest.tscn"))

func _on_debug_info_toggle_toggled(toggled_on) -> void:
	Global.debug_gui.visible = toggled_on
