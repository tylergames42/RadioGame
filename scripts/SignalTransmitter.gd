@icon("res://assets/ui/editor/icons/radio_tower.svg")
class_name SignalTransmitter
extends Node3D

@export var STREAMS : Array[AudioStream]
@export var SHUFFLE_AUDIO : bool = true ##If the audio should be played randomly
@export_range(-20.0, 1.0, 0.1) var VOLUME : float = 0.0
@export_range(0.0, 100.0, 1.0) var FREQUENCY : float ##TODO: change to use range of frequencies instead?
													##Then some signals could be broader than others or take up whole range for scripted events.
@export_range(0.0, 100.0, 1.0) var FREQUENCY_MIN : float
@export_range(0.0, 100.0, 1.0) var FREQUENCY_MAX : float
@export_range(0.0, 10000.0, 1.0) var RANGE_PARTIAL : float ##Range (in meters) for when you can start to pick up the signal (make higher)
@export_range(0.0, 10000.0, 1.0) var RANGE_FULL : float ##Range (in meters) for when signal gets to full strength (make lower)
@export var TEST : Gradient

@onready var AudioPlayer = AudioStreamPlayer.new()

var current_stream : AudioStream
var rand_counter : int = 0

func _ready():
	STREAMS.shuffle()
	add_child(AudioPlayer)
	AudioPlayer.bus = "Radio"
	AudioPlayer.volume_db = -100.0
	play_audio()
	
	if RANGE_PARTIAL <= RANGE_FULL: #Make sure any parameters aren't fucked up
		push_error("Signal " + str(name) + "'s ranges are configured incorrectly!")
	if FREQUENCY_MIN <= FREQUENCY_MAX:
		push_error("Signal " + str(name) + "'s frequencies are configured incorrectly!")

func update_strength(new_strength : float):
	if !AudioPlayer.playing:
			play_audio()
	if new_strength > 0.9:
		AudioPlayer.volume_db = VOLUME
	elif new_strength < 0.01:
		AudioPlayer.volume_db = -80.0
	else:
		AudioPlayer.volume_db = remap(new_strength, 0.0, 1.0, VOLUME - 20.0, VOLUME)
		
func get_signal_playback_pos() -> float:
	return AudioPlayer.get_playback_position()
		
func get_signal_stream() -> AudioStream:
	return current_stream
	
func get_signal_strength(pos : Transform3D, frequency : float) -> float:
	var freq_diff = absf(FREQUENCY - frequency) #Get difference in our frequency and transmitter's
	freq_diff = clampf(freq_diff, 0.0, 1.0) #Clamp difference to value between 0.0 and 1.0
	var distance = global_position.distance_to(global_position) #Get distance to transmitter
	if (distance <= RANGE_PARTIAL): #Start recieving signal if in range and freq
		distance = clampf(distance, RANGE_FULL, RANGE_PARTIAL)
		distance = remap(distance, RANGE_FULL, RANGE_PARTIAL, 0.0, 1.0)
		var signal_strength = (1-distance) * (1-freq_diff) #New signal strength calculation
		return signal_strength
	else:
		return 0.0
		
func play_audio(): ##TODO add weight?
	if STREAMS.size() < 1: #Make sure signal actually has audio
		push_error(str(name) + " has no streams assigned!")
		return
	
	current_stream = STREAMS[0]
	AudioPlayer.stream = current_stream
	AudioPlayer.play()
	STREAMS.remove_at(0)
	STREAMS.append(current_stream)
	
	if SHUFFLE_AUDIO == false:
		return
	#Shuffle the audio once all streams have played (arrays are goated)	
	rand_counter += 1
	if rand_counter > STREAMS.size():
		STREAMS.shuffle()
		rand_counter = 0
