extends Node3D

@onready var anim = $AnimationPlayer

var stock_open = false

func _input(event):
	if Input.is_action_just_pressed("fire_main") and !anim.is_playing():
		anim.play("fire")
	if Input.is_action_just_pressed("fire_alt") and !anim.is_playing():
		if stock_open:
			anim.play("stock_close")
			stock_open = false
		else:
			anim.play("stock_open")
			stock_open = true
	if Input.is_action_just_pressed("kick"):
		if self.visible:
			hide()
		else:
			show()
