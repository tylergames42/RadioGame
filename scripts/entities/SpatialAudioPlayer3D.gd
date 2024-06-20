class_name SpatialAudioPlayer3D
extends AudioStreamPlayer3D

#@export_enum("X:0","Y:1","Z:2") var AXIS = 1
@export var UPDATE_ONLY_ON_PLAY : bool = true ##If the audio player should only update when played (use for short audio clips)
@export var UPDATE_FREQUENCY : float = 0.5 ##The frequency to update audio if update only on play is false
@export var MAX_RAYCAST_DISTANCE : float = 25.0

var raycast_array : Array = []
var distance_array : Array = []
var direction_array : Array = []
var last_update_time : float = 0.0

@onready var starting_volume = volume_db
var audio_bus_idx
var reverb_effect
var lowpass_effect

var target_lowpass_cutoff : float = 20000
var target_reverb_room_size : float = 0.0
var target_reverb_wetness : float = 0.0
var target_reverb_damping : float = 0.0
var target_volume_db : float = 0.0

func _ready():
	audio_bus_idx = AudioServer.bus_count #Setup audio bus shit
	AudioServer.add_bus(audio_bus_idx)
	AudioServer.set_bus_name(audio_bus_idx, "Spatial")
	AudioServer.set_bus_send(audio_bus_idx, bus)
	self.bus = "Spatial"
	
	AudioServer.add_bus_effect(audio_bus_idx, AudioEffectReverb.new(), 0)
	reverb_effect = AudioServer.get_bus_effect(audio_bus_idx, 0)
	AudioServer.add_bus_effect(audio_bus_idx, AudioEffectLowPassFilter.new(), 1)
	lowpass_effect = AudioServer.get_bus_effect(audio_bus_idx, 1)
	
	setup_direction_array()
	
	playing = false #Stop the sound from playing so we can use our own play function
	if autoplay: 
		spatial_play()
	
func spatial_play():
	update_reverb()
	#update_occlusion()
	play()
	
func _process(delta):
	lerp_parameters(delta)

func _physics_process(delta):
	if !UPDATE_ONLY_ON_PLAY:
		last_update_time += delta
		if last_update_time > 1.0:
			update_reverb()
			#update_occlusion()
			last_update_time = 0.0

func setup_direction_array(): #Create array of directions to use in spatial audio calculations
	direction_array.clear()
	direction_array.append(Vector3(0,MAX_RAYCAST_DISTANCE,0)) #Add UP direction
	direction_array.append(Vector3(0,-MAX_RAYCAST_DISTANCE,0)) #Add DOWN direction
	direction_array.append(Vector3(0,0,-MAX_RAYCAST_DISTANCE)) #Add NORTH direction
	direction_array.append(Vector3(MAX_RAYCAST_DISTANCE,0,0)) #Add EAST direction
	direction_array.append(Vector3(0,0,MAX_RAYCAST_DISTANCE)) #Add SOUTH direction
	direction_array.append(Vector3(-MAX_RAYCAST_DISTANCE,0,0)) #Add WEST direction
	direction_array.append(Vector3(MAX_RAYCAST_DISTANCE,0,-MAX_RAYCAST_DISTANCE)) #Add NE direction
	direction_array.append(Vector3(MAX_RAYCAST_DISTANCE,0,MAX_RAYCAST_DISTANCE)) #Add SE direction
	direction_array.append(Vector3(-MAX_RAYCAST_DISTANCE,0,MAX_RAYCAST_DISTANCE)) #Add SW direction
	direction_array.append(Vector3(-MAX_RAYCAST_DISTANCE,0,-MAX_RAYCAST_DISTANCE)) #Add NW direction
	##more directions (temp?):
	direction_array.append(Vector3(0,MAX_RAYCAST_DISTANCE,-MAX_RAYCAST_DISTANCE)) #Add UP NORTH direction
	direction_array.append(Vector3(MAX_RAYCAST_DISTANCE,MAX_RAYCAST_DISTANCE,0)) #Add UP EAST direction
	direction_array.append(Vector3(0,MAX_RAYCAST_DISTANCE,MAX_RAYCAST_DISTANCE)) #Add UP SOUTH direction
	direction_array.append(Vector3(-MAX_RAYCAST_DISTANCE,MAX_RAYCAST_DISTANCE,0)) #Add UP WEST direction
	direction_array.append(Vector3(0,-MAX_RAYCAST_DISTANCE,-MAX_RAYCAST_DISTANCE)) #Add DOWN NORTH direction
	direction_array.append(Vector3(MAX_RAYCAST_DISTANCE,-MAX_RAYCAST_DISTANCE,0)) #Add DOWN EAST direction
	direction_array.append(Vector3(0,-MAX_RAYCAST_DISTANCE,MAX_RAYCAST_DISTANCE)) #Add DOWN SOUTH direction
	direction_array.append(Vector3(-MAX_RAYCAST_DISTANCE,-MAX_RAYCAST_DISTANCE,0)) #Add DOWN WEST direction

func update_reverb(): #Update reverb effect parameters
	var room_size = 0.0
	var wetness = 0.0
	var damping = 0.0
	
	var space_state = get_world_3d().direct_space_state #Stuff for raycast
	var origin = self.global_position
	
	for direction in direction_array:
		var query = PhysicsRayQueryParameters3D.create(origin, origin + direction)
		query.exclude = [get_parent()]
		var collision = space_state.intersect_ray(query)
		if collision:
			var collider = collision.collider
			if "physics_material_override" in collider:
				if collider.physics_material_override is MaterialProperties:
					var distance = origin.distance_to(collision.position)
					room_size += (distance / MAX_RAYCAST_DISTANCE) / (float(direction_array.size()))
					damping += (collider.physics_material_override.DAMPING / float(direction_array.size()))
					wetness += (collider.physics_material_override.REVERB_CONTRIBUTION / float(direction_array.size()))
	target_reverb_room_size = min(room_size, 1.0)
	target_reverb_wetness = clampf(wetness - 0.1, 0.0, 0.9)
	target_reverb_damping = clampf(1.0 - damping, 0.0, 1.0)
	
	#DEBUG PRINT
	#print(str(self.name) + " Room Size: " + str(reverb_effect.room_size) + " Damping: " + str(damping) + " Wetness: " + str(reverb_effect.wet))
	
#func update_occlusion():
	#var audio_listener = get_viewport().get_camera_3d()
	#var lowpass_cutoff = 20000
	#
	#var space_state = get_world_3d().direct_space_state #Stuff for raycast
	#var origin = self.global_position
	#var query = PhysicsRayQueryParameters3D.create(origin, audio_listener.global_position)
	#query.exclude = [get_parent()]
	#var collision = space_state.intersect_ray(query)
	#if collision:
		#var collider = collision.collider
		#if "physics_material_override" in collider:
			#if collider.physics_material_override is MaterialProperties:
				#var ray_distance = origin.distance_to(collision.position)
				#var distance_to_player = origin.distance_to(audio_listener.global_position)
				#var wall_to_player_ratio = ray_distance / max(distance_to_player, 0.001)
				#lowpass_cutoff = 100.0 * wall_to_player_ratio
				#
	#print(lowpass_effect.cutoff_hz)
	#target_lowpass_cutoff = 100
	
func lerp_parameters(delta): #Set and lerp effect parameters
	#volume_db = lerp(volume_db, target_volume_db, delta)
	lowpass_effect.cutoff_hz = lerp(lowpass_effect.cutoff_hz, target_lowpass_cutoff, delta * 5.0)
	reverb_effect.wet = lerp(reverb_effect.wet, target_reverb_wetness, delta * 5.0)
	reverb_effect.room_size = lerp(reverb_effect.room_size, target_reverb_room_size, delta * 5.0)
	reverb_effect.damping = lerp(reverb_effect.damping, target_reverb_damping, delta * 5.0)
	
