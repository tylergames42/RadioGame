class_name SignalTransmitter
extends Node3D

@export var AUDIO : AudioStream
@export var SPECTROGRAM : Texture2D
@export_range(-20.0, 1.0, 0.1) var VOLUME : float = 0.0
@export_range(0.0, 100.0, 1.0) var FREQUENCY : float
@export_range(0.0, 10000.0, 1.0) var RANGE_PARTIAL : float ##Range for when you can start to pick up the signal (make higher)
@export_range(0.0, 10000.0, 1.0) var RANGE_FULL : float ##Range for when signal gets to full strength (make lower)
@export_category("Start Time")
@export var RANDOM_START_TIME : bool = false
@export var START_TIME : float = 0.0

@onready var AudioPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(AudioPlayer)
	AudioPlayer.bus = "Radio"
	AudioPlayer.stream = AUDIO
	if RANDOM_START_TIME:
		START_TIME = randf_range(0.0, AUDIO.get_length())
	AudioPlayer.volume_db = -100.0

func update_strength(new_strength : float):
	if !AudioPlayer.playing:
			AudioPlayer.play(START_TIME)
	if new_strength >= 0.9:
		AudioPlayer.volume_db = VOLUME
	elif new_strength <= 0.1:
		AudioPlayer.volume_db = -80.0
	else:
		AudioPlayer.volume_db = remap(new_strength, 0.0, 1.0, VOLUME - 20.0, VOLUME)
