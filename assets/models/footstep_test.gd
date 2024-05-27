extends Node3D

@onready var AudioPlayer = AudioStreamPlayer3D.new()
var offset

func _ready():
	add_child(AudioPlayer)

func step_sound(right : bool):
	print("CUM")
	var raycast = RayCast3D.new()
	if right:
		offset = 0.25
	else:
		offset = -0.25
	raycast.global_position = get_parent().global_position
	raycast.target_position = get_parent().global_position - Vector3(0, -5, 0)
	DebugDraw3D.draw_ray(raycast.global_position, raycast.target_position, 2)
	if raycast.is_colliding():
		print(raycast.get_collider())
	if raycast.is_colliding() and raycast.get_collider().has_meta("MaterialProperties"):
		print("ASS")
		AudioPlayer.stream = raycast.get_collider().SFX_SCRAPE
		AudioPlayer.play()
