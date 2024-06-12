extends WeaponBase

@export var DESIRED_FREQUENCY = 10.0
@export var STATIC : AudioStream
@export_range(-20.0, 0.0, 1.0) var STATIC_VOLUME : float = -20.0

@export_group("Visuals")
#@export var ANIM_TREE : AnimationTree
@export var MAT_STRENGTH_GRADIENT : Gradient
@export var MAT_OSC : ShaderMaterial
@export var MAT_SPECTROGRAM : ShaderMaterial
@export var MAT_STRENGTH_IND : ShaderMaterial
@export var MAT_AUDIO_IND : ShaderMaterial

@onready var signal_manager = Global.signal_manager
@onready var static_player = AudioStreamPlayer.new()
@onready var radio_bus_listener = AudioServer.get_bus_effect_instance(2,0)

var reciever_signal_strength = 0.0
var connected_signal : SignalTransmitter
var signal_strengths : float
var in_range_of_signals : bool = false

var frequency : float = 0.0

func _ready():
	add_child(static_player)
	static_player.bus = "RadioStatic"
	static_player.stream = STATIC
	static_player.play()
	static_player.volume_db = STATIC_VOLUME
	
func input_update(event):
	if frequency < 99.9 and event.is_action_pressed("tune_up"):
		if Input.is_action_pressed("tune_modifiy"):
			DESIRED_FREQUENCY += 1
		else:
			DESIRED_FREQUENCY += 0.1
				
		static_player.play()
		static_player.seek(randf_range(0.0, 10.0))
	if frequency > 0.1 and event.is_action_pressed("tune_down"):
		if Input.is_action_pressed("tune_modifiy"):
			DESIRED_FREQUENCY -= 1
		else:
			DESIRED_FREQUENCY -= 0.1
				
		static_player.play()
		static_player.seek(randf_range(0.0, 10.0))
		
	if event.is_action_pressed("tune_up_large", true):
		DESIRED_FREQUENCY += 10
	if event.is_action_pressed("tune_down_large", true):
		DESIRED_FREQUENCY -= 10
	
	if Input.is_key_pressed(KEY_1):
		DESIRED_FREQUENCY = 10
	if Input.is_key_pressed(KEY_2):
		DESIRED_FREQUENCY = 20
	if Input.is_key_pressed(KEY_3):
		DESIRED_FREQUENCY = 30
	if Input.is_key_pressed(KEY_4):
		DESIRED_FREQUENCY = 40
	if Input.is_key_pressed(KEY_5):
		DESIRED_FREQUENCY = 50
	if Input.is_key_pressed(KEY_6):
		DESIRED_FREQUENCY = 60
	if Input.is_key_pressed(KEY_7):
		DESIRED_FREQUENCY = 60
	if Input.is_key_pressed(KEY_8):
		DESIRED_FREQUENCY = 80
	if Input.is_key_pressed(KEY_9):
		DESIRED_FREQUENCY = 90
		
	DESIRED_FREQUENCY = clamp(DESIRED_FREQUENCY, 0.1, 99.9)
	
	if event.is_action_released("tune_modifiy") or event.is_action_released("tune_up_large") or event.is_action_released("tune_down_large"):
		DESIRED_FREQUENCY = frequency
		
func update(delta):
	frequency = lerpf(frequency, DESIRED_FREQUENCY, delta * 5)
	Global.frequency = frequency
	update_visuals(delta)
	
	#var tune_speed = clamp(DESIRED_FREQUENCY - frequency, -1, 1) * 0.5
	#if ANIM_TREE["parameters/tune_anim/time"] != null:
		#ANIM_TREE["parameters/tune_speed/scale"] = tune_speed
		#var anim_time = ANIM_TREE["parameters/tune_anim/time"]
		#frequency = remap(anim_time, 0.0, 1.25, 0.1, 100.0)
		#Global.frequency = frequency
		#update_visuals(delta)
	
	in_range_of_signals = false
	reciever_signal_strength = 0.0
	find_signals()
	
	Global.signal_strength = reciever_signal_strength
	if connected_signal != null:
		Global.connected_signal_name = connected_signal.name
	else:
		Global.connected_signal_name = "none"

func find_signals():
	for sig in signal_manager.get_children():
		if sig is SignalTransmitter:
			var freq_diff = absf(sig.FREQUENCY - frequency) #Get difference in our frequency and transmitter's
			freq_diff = clampf(freq_diff, 0.0, 1.0) #Clamp difference to value between 0.0 and 1.0
			var distance = global_position.distance_to(sig.global_position) #Get distance to transmitter
			if (distance <= sig.RANGE_PARTIAL): #Start recieving signal if in range and freq
				in_range_of_signals = true
				if (freq_diff < 1.0):
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
					
func update_visuals(delta):
	var strength = reciever_signal_strength
	if in_range_of_signals:
		strength += 0.05
	ANIM_TREE["parameters/TimeSeek/seek_request"] = remap(frequency, 0.0, 100.0, 0.0, 1.25)
	MAT_OSC.set_shader_parameter("freq", frequency * 0.5)
	MAT_STRENGTH_IND.set_shader_parameter("emission", MAT_STRENGTH_GRADIENT.sample(strength))
	MAT_AUDIO_IND.set_shader_parameter("emission_energy", radio_bus_listener.get_magnitude_for_frequency_range(0, 10000).length() * 20)
	
