extends Node3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("pause"):
		if Global.paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Global.paused = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Global.paused = true
	
	if event.is_action_pressed("reload"):
		var _reload = get_tree().reload_current_scene()
