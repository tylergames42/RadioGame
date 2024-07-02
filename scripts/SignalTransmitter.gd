@icon("res://assets/ui/editor/icons/radio_tower.svg")
class_name SignalTransmitter
extends Node3D

@export var STREAMS : Array[AudioStream]
@export_range(-20.0, 1.0, 0.1) var VOLUME : float = 0.0
@export_range(0.0, 100.0, 1.0) var FREQUENCY : float ##TODO: change to use range of frequencies instead?
													##Then some signals could be broader than others or take up whole range for scripted events.
@export_range(0.0, 10000.0, 1.0) var RANGE_PARTIAL : float ##Range for when you can start to pick up the signal (make higher)
@export_range(0.0, 10000.0, 1.0) var RANGE_FULL : float ##Range for when signal gets to full strength (make lower)
@export_range(0.0, 1.0, 0.1) var STRENGTH_MULTIPLIER : float ##TODO?

@onready var AudioPlayer = AudioStreamPlayer.new()

var current_stream : AudioStream
var rand_counter : int = 0

func _ready():
	STREAMS.shuffle()
	add_child(AudioPlayer)
	AudioPlayer.bus = "Radio"
	AudioPlayer.volume_db = -100.0
	play_audio_random()

func update_strength(new_strength : float):
	if !AudioPlayer.playing:
			play_audio_random()
	if new_strength > 0.9:
		AudioPlayer.volume_db = VOLUME
	elif new_strength < 0.01:
		AudioPlayer.volume_db = -80.0
	else:
		AudioPlayer.volume_db = remap(new_strength, 0.0, 1.0, VOLUME - 20.0, VOLUME)
		
func play_audio_random(): ##TODO add weight?
	if STREAMS.size() < 1:
		push_error(str(name) + " has no streams assigned!")
		return
	
	current_stream = STREAMS[0]
	AudioPlayer.stream = current_stream
	AudioPlayer.play()
	STREAMS.remove_at(0)
	STREAMS.append(current_stream)
	
	rand_counter += 1
	if rand_counter > STREAMS.size():
		STREAMS.shuffle()
		rand_counter = 0
