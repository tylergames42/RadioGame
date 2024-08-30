@icon("res://assets/ui/editor/icons/radio_tower.svg")
class_name SignalTransmitter
extends Node3D

signal recieving ##Emitted when the signal is being recieved

@export var STREAMS : Array[AudioStream]
@export var SHUFFLE_AUDIO : bool = true ##If the audio should be played randomly
@export_range(-20.0, 1.0, 0.1) var VOLUME : float = 0.0
@export var FREQUENCY_MAP : Gradient ##Gradient for setting the range of frequency strength. Alpha channel is strength. (yes this was the easiest way to do this)
@export_range(0.0, 10000.0, 1.0) var RANGE_PARTIAL : float ##Range (in meters) for when you can start to pick up the signal (make higher)
@export_range(0.0, 10000.0, 1.0) var RANGE_FULL : float ##Range (in meters) for when signal gets to full strength (make lower)

@onready var audio_player = AudioStreamPlayer.new()

var current_stream : AudioStream
var rand_counter : int = 0

func _ready():
	STREAMS.shuffle()
	add_child(audio_player)
	audio_player.bus = "Radio"
	audio_player.volume_db = -100.0
	play_audio()
	
	if RANGE_PARTIAL <= RANGE_FULL: #Make sure any parameters aren't fucked up
		push_error("Signal " + str(name) + "'s ranges are configured incorrectly!")
	if FREQUENCY_MAP == null:
		push_error("Signal " + str(name) + " does not have a frequency map!")
		
func get_signal_playback_pos() -> float:
	return audio_player.get_playback_position()
		
func get_signal_stream() -> AudioStream:
	return current_stream
	
func get_signal_strength(pos : Vector3, frequency : float) -> float:
	if FREQUENCY_MAP == null: #Crash prevention for signals that aren't set up
		push_error("Signal " + str(name) + " does not have a frequency map!")
		return 0.0
	var freq_strength = FREQUENCY_MAP.sample(frequency).a #Get strength of signal at frequency
	var distance = global_position.distance_to(pos) #Get distance to transmitter
	if (distance <= RANGE_PARTIAL): #Start recieving signal if in range and freq
		distance = clampf(distance, RANGE_FULL, RANGE_PARTIAL)
		distance = remap(distance, RANGE_FULL, RANGE_PARTIAL, 0.0, 1.0)
		var signal_strength = (1-distance) * freq_strength #New signal strength calculation
		return signal_strength
	else:
		return 0.0

func is_in_range(pos : Vector3) -> bool:
	var distance = global_position.distance_to(pos) #Get distance to transmitter
	if (distance <= RANGE_PARTIAL):
		return true
	else:
		return false

func update_strength(new_strength : float):
	if !audio_player.playing:
		play_audio()
	if new_strength < 0.01:
		audio_player.volume_db = -80.0
	elif new_strength > 0.99:
		audio_player.volume_db = VOLUME
		emit_signal("recieving")
	else:
		audio_player.volume_db = remap(new_strength, 0.0, 1.0, VOLUME - 20.0, VOLUME)
		
func play_audio(): ##TODO add weight?
	if STREAMS.size() < 1: #Make sure signal actually has audio
		push_error(str(name) + " has no streams assigned!")
		return
	
	current_stream = STREAMS[0]
	audio_player.stream = current_stream
	audio_player.play()
	STREAMS.remove_at(0)
	STREAMS.append(current_stream)
	
	if SHUFFLE_AUDIO == false:
		return
	#Shuffle the audio once all streams have played (arrays are goated)	
	rand_counter += 1
	if rand_counter > STREAMS.size():
		STREAMS.shuffle()
		rand_counter = 0
