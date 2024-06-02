extends Node3D


@export var SIGNAL_MANAGER : Node3D
@export var STARTING_FREQUENCY = 10.0
@export var STATIC : AudioStream
@export_range(-20.0, 0.0, 1.0) var STATIC_VOLUME : float = -10.0

@export_group("Visuals")
@export var ANIM_TREE : AnimationTree
@export var MAT_OSC : ShaderMaterial
@export var MAT_STRENGTH_IND : ShaderMaterial

@onready var static_player = AudioStreamPlayer.new()

var reciever_signal_strength = 0.0
var connected_signal : SignalTransmitter
var signal_strengths : float

var frequency : float = 0.0
var desired_frequency : float = 33.0

func _ready():
	add_child(static_player)
	static_player.bus = "RadioStatic"
	static_player.stream = STATIC
	static_player.play()
	static_player.volume_db = STATIC_VOLUME

func _input(event):
	if frequency < 99.9 and event.is_action_pressed("tune_up"):
		if Input.is_action_pressed("tune_modifiy"):
			desired_frequency += 10
		else:
			desired_frequency += 0.1
			
		if desired_frequency > 99.9:
				desired_frequency = 99.9
				
		static_player.play()
		static_player.seek(randf_range(0.0, 10.0))
	if frequency > 0.1 and event.is_action_pressed("tune_down"):
		if Input.is_action_pressed("tune_modifiy"):
			desired_frequency -= 10
		else:
			desired_frequency -= 0.1
			
		if desired_frequency < 0.1:
				desired_frequency = 0.1
				
		static_player.play()
		static_player.seek(randf_range(0.0, 10.0))
	if event.is_action_released("tune_modifiy"):
		desired_frequency = frequency

func _process(delta):
	print(desired_frequency)
	
	var freq_diff = (desired_frequency - frequency)
	var tune_speed = clamp(desired_frequency - frequency, -1, 1) * 0.5
	
	if ANIM_TREE["parameters/tune_anim/time"] != null:
		ANIM_TREE["parameters/tune_speed/scale"] = tune_speed
		var anim_time = ANIM_TREE["parameters/tune_anim/time"]
		frequency = remap(anim_time, 0.0, 1.25, 0.1, 100.0)
		Global.frequency = frequency
		update_visuals()
	#
	
	reciever_signal_strength = 0.0
	find_signals()
	
	Global.signal_strength = reciever_signal_strength
	if connected_signal != null:
		#static_player.volume_db = STATIC_VOLUME - 25.0
		Global.connected_signal_name = connected_signal.name
	else:
		#static_player.volume_db = STATIC_VOLUME
		Global.connected_signal_name = "none"

func find_signals():
	for sig in SIGNAL_MANAGER.get_children():
		if sig is SignalTransmitter:
			var freq_diff = absf(sig.FREQUENCY - frequency) #Get difference in our frequency and transmitter's
			freq_diff = clampf(freq_diff, 0.0, 1.0) #Clamp difference to value between 0.0 and 1.0
			var distance = global_position.distance_to(sig.global_position) #Get distance to transmitter
			if (freq_diff < 1.0) && (distance <= sig.RANGE_PARTIAL): #Start recieving signal if in range and freq
				distance = clampf(distance, sig.RANGE_FULL, sig.RANGE_PARTIAL)
				distance = remap(distance, sig.RANGE_FULL, sig.RANGE_PARTIAL, 0.0, 1.0)
				#var signal_strength = 1 - ((freq_diff + distance)/2) #Calculate signal strength OLD
				var signal_strength = (1-distance) * (1-freq_diff) #New signal strength calculation
				sig.update_strength(signal_strength) #Update signal strength for reciever
				static_player.volume_db = remap(signal_strength, 1.0, 0.0, -60.0, STATIC_VOLUME)
				if signal_strength >= 0.9: #Set connected signal if strength is high enough
					connected_signal = sig
				elif sig == connected_signal:
					connected_signal = null
				reciever_signal_strength += signal_strength
			else:
				sig.update_strength(0.0)
				if sig == connected_signal:
					connected_signal = null
					
func tune(amount : float):
	if amount > 0.0:
		pass
	elif amount < 0.0:
		pass
	else:
		return
					
func update_visuals():
	MAT_OSC.set_shader_parameter("freq", frequency)
	#MAT_STRENGTH_IND.set_shader_parameter("strength", reciever_signal_strength)
