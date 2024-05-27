extends Node3D

@export var anim_player : AnimationPlayer

func _ready():
	anim_player.play("indicator_move", -1, 0.0)
	
func _input(event):
	anim_player.seek(remap(Global.frequency, 1.0, 100.0, 0.0, 1.0))
