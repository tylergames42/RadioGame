extends Node3D
class_name SignalReciever

@export var SIGNAL_MANAGER : Node3D
@export var FREQUENCY = 10.0 ##The frequency to start the reciever at

@export var STATIC : AudioStream
@export_range(-20.0, 0.0, 1.0) var STATIC_VOLUME : float = -10.0
@onready var StaticPlayer = AudioStreamPlayer.new()

var reciever_signal_strength = 0.0
var connected_signal : SignalTransmitter
var signal_strengths : float

func _ready():
	add_child(StaticPlayer)
	StaticPlayer.bus = "RadioStatic"
	StaticPlayer.stream = STATIC
	StaticPlayer.play()
	StaticPlayer.volume_db = STATIC_VOLUME
	StaticPlayer.finished.connect(static_finished)
	
func static_finished():
	StaticPlayer.play()

func _input(event):
	Global.frequency = FREQUENCY
	if event.is_action_pressed("tune_up"):
		StaticPlayer.play()
		StaticPlayer.seek(randf_range(0.0, 10.0))
		if Input.is_action_pressed("tune_modifiy"):
			FREQUENCY += 1.0
		else:
			FREQUENCY += 0.1
		if FREQUENCY > 100.0:
			FREQUENCY = 100.0
	if event.is_action_pressed("tune_down"):
		StaticPlayer.play()
		StaticPlayer.seek(randf_range(0.0, 10.0))
		if Input.is_action_pressed("tune_modifiy"):
			FREQUENCY -= 1.0
		else:
			FREQUENCY -= 0.1
		if FREQUENCY < 1.0:
			FREQUENCY = 1.0



func _process(delta):
	reciever_signal_strength = 0.0
	find_signals()
	
	Global.signal_strength = reciever_signal_strength
	if connected_signal != null:
		StaticPlayer.volume_db = STATIC_VOLUME - 25.0
		Global.connected_signal_name = connected_signal.name
	else:
		StaticPlayer.volume_db = STATIC_VOLUME
		Global.connected_signal_name = "none"

func find_signals():
	for sig in SIGNAL_MANAGER.get_children():
		if sig is SignalTransmitter:
			var freq_diff = absf(sig.FREQUENCY - FREQUENCY) #Get difference in our frequency and transmitter's
			freq_diff = clampf(freq_diff, 0.0, 1.0) #Clamp difference to value between 0.0 and 1.0
			var distance = global_position.distance_to(sig.global_position) #Get distance to transmitter
			if (freq_diff < 1.0) && (distance <= sig.RANGE_PARTIAL): #Start recieving signal if in range and freq
				distance = clampf(distance, sig.RANGE_FULL, sig.RANGE_PARTIAL)
				distance = remap(distance, sig.RANGE_FULL, sig.RANGE_PARTIAL, 0.0, 1.0)
				#var signal_strength = 1 - ((freq_diff + distance)/2) #Calculate signal strength OLD
				var signal_strength = (1-distance) * (1-freq_diff) #New signal strength calculation
				sig.update_strength(signal_strength) #Update signal strength for reciever
				if signal_strength >= 0.9: #Set connected signal if strength is high enough
					connected_signal = sig
				elif sig == connected_signal:
					connected_signal = null
				reciever_signal_strength += signal_strength
			else:
				sig.update_strength(0.0)
				if sig == connected_signal:
					connected_signal = null
