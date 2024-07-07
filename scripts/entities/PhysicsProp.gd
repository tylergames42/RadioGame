@icon("res://assets/ui/editor/icons/wooden_crate.svg")
class_name PhysicsProp
extends RigidBody3D

@export_range(0.0, 5.0 , 0.1) var BUOYANCY : float = 0.0
@export var SELF_PHYS_DAMAGE_MULTIPLIER : float = 0.2 ##Multiplier for physics damage dealt to self on impact
@export var OTHER_PHYS_DAMAGE_MULTIPLIER : float = 0.8 ##Multiplier for physics damage dealt to others on impact
#@export_range(0.5, 1.5) var PHYS_IMPACT_SENSITIVITY = 1.0 ##Multipler for the sensitivty of impact sounds
@export_group("Damage")
@export var GIBS : PackedScene ##Gibs to spawn when object is broken (Unused if breakable prop is not breakable)
@export_group("Carrying")
@export var DEFAULT_HOLD_VECTOR : Vector3 = Vector3.UP ##Default orientation when picked up
@export var THROW_FORCE : float = 6 ##Throwing force multipler

@onready var audio_player = SpatialAudioPlayer3D.new() #Create new 3D Audio Player for physics sounds

var holder
var distance : float
var held : bool = false
var prev_velocity : Vector3

func _ready(): #Set up physics prop properties
	add_child(audio_player)
	audio_player.doppler_tracking = audio_player.DOPPLER_TRACKING_PHYSICS_STEP
	max_contacts_reported = 1
	contact_monitor = true
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	OTHER_PHYS_DAMAGE_MULTIPLIER = OTHER_PHYS_DAMAGE_MULTIPLIER * (mass * 0.05)
	BUOYANCY = BUOYANCY * mass
			
func _integrate_forces(_state):
	prev_velocity = linear_velocity
	
	if held:
		distance = global_transform.origin.distance_to(holder.hold_point.global_transform.origin)
		var velocity_multipler = 10 / (snapped(distance, 0.2) + 0.3)
		var target_velocity = (holder.hold_point.global_transform.origin - global_transform.origin) * velocity_multipler
		var impulse_vector = target_velocity - linear_velocity
		apply_central_impulse(impulse_vector + holder.linear_velocity)
			
	if get_colliding_bodies() != [] and get_colliding_bodies()[0]: #Scrape sfx (kinda jank rn)
		if held:
			if distance > 2.5:
				drop()
		if physics_material_override != null:
			if linear_velocity.length() > 4 and angular_velocity.length() < 2.5: #Angular velocity check is to prevent rolling objects from scraping (could seperate for rolling sfx later if wanted)
				if !audio_player.playing:
					audio_player.stream = physics_material_override.SFX_SCRAPE
					audio_player.spatial_play()
			elif audio_player.stream == physics_material_override.SFX_SCRAPE:
				audio_player.stop()
	
func carry():
	sleeping = false
	can_sleep = false
	held = true
	holder.hold_point.set_node_b(get_path())
	holder.held_object = self
	add_collision_exception_with(holder)
	holder.weapon_manager.holster_active()
	
func drop():
	sleeping = false
	can_sleep = true
	held = false
	holder.hold_point.set_node_b("")
	holder.held_object = null
	remove_collision_exception_with(holder)
	holder.weapon_manager.draw_active()
	
func throw(throw_dir):
	drop()
	apply_central_impulse(throw_dir * mass * THROW_FORCE)

func _on_body_entered(body):
	var velocity = prev_velocity.length()
	if body is PhysicsProp:
		velocity = abs(linear_velocity - body.linear_velocity).length()
	if held: #Fix for held props breaking while moving
		velocity *= 0.5
	if velocity > 6: #Do hard physics impact
		if physics_material_override != null and !audio_player.playing:
			audio_player.stream = physics_material_override.SFX_IMPACT_HARD
			audio_player.play()
		if body.has_meta("HealthComponent"):
			body.get_meta("HealthComponent", null).damage(velocity * OTHER_PHYS_DAMAGE_MULTIPLIER)
		if self.has_meta("HealthComponent"):
			self.get_meta("HealthComponent", null).damage(velocity * SELF_PHYS_DAMAGE_MULTIPLIER)
	elif velocity > 2: #Do soft physics impact
		if physics_material_override != null and !audio_player.playing:
			audio_player.stream = physics_material_override.SFX_IMPACT_SOFT
			audio_player.spatial_play()
			
func _on_body_exited(_body):
	if audio_player.playing and audio_player.stream == physics_material_override.SFX_SCRAPE: #Fix for scrape noises still playing after object is pciked up
		audio_player.stop()

func _on_interactable_component_interacted(interacter):
	holder = interacter
	if held:
		drop()
	else:
		carry()

func _on_health_component_killed():
	if GIBS != null:
		var gib = GIBS.instantiate()
		get_parent().add_child(gib)
		gib.global_transform = global_transform
		for child in gib.get_children():
			if child is RigidBody3D:
				child.apply_central_impulse(linear_velocity / (randf() + 0.6))
	queue_free()
