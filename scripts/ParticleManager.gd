extends AudioStreamPlayer3D
class_name ParticleManager

@export var LIFETIME : float = 1.0

func _ready():
	var timer = Timer.new()
	timer.wait_time = LIFETIME
	timer.timeout.connect(kill)
	timer.autostart = true
	
	for child in get_children():
		if child is GPUParticles3D or CPUParticles3D:
			child.emitting = true

func kill():
	queue_free()
