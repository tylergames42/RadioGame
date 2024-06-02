extends Node3D

var anim_player
var mesh

func _ready():
	for child in get_children():
		if child is AnimationPlayer:
			anim_player = child
		elif child is MeshInstance3D:
			mesh = child
	anim_player.play("radio_tune", -1, 0.0)
	
func _input(event):
	anim_player.play("radio_tune", -1, 0.0)
	anim_player.seek(remap(Global.frequency, 1.0, 100.0, 0.0, 2.0))
	
	for body in get_overlapping_bodies():
		if body.name = ""
