extends Area3D

@export var SPLASH : PackedScene

@onready var surface = get_parent()
var surface_height

func _ready():
	surface_height = surface.global_transform.origin.y

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body is PhysicsProp:
			var depth = surface_height - body.global_position.y
			if depth > 0:
				body.apply_central_impulse(Vector3.UP * (depth / 2) * body.BUOYANCY)

func _on_body_entered(body):
	if body is RigidBody3D:
		if body.linear_velocity.length() > 3.0:
			var splash_effect = SPLASH.instantiate()
			add_child(splash_effect)
			splash_effect.global_transform.origin = Vector3(body.global_position.x, surface_height + 0.001, body.global_position.z)
			splash_effect.emitting = true
	
	if body == Global.player:
		body.state_machine.on_child_transition("PlayerSwimmingState")

func _on_body_exited(body):
	if body == Global.player:
		body.state_machine.on_child_transition("PlayerIdleState")
