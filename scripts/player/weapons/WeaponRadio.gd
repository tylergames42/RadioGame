extends WeaponBase

@export var DESIRED_FREQUENCY = 0.1
@export var STATIC : AudioStream
@export_range(-20.0, 0.0, 1.0) var RADIO_VOLUME : float = 0.0
@export_range(-20.0, 0.0, 1.0) var STATIC_VOLUME : float = -20.0

@export_group("Visuals")
#@export var ANIM_TREE : AnimationTree
@export var GRADIENT_STRENGTH : Gradient
@export var GRADIENT_SPECTROGRAM : Gradient
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
var frequency : float = 0.0

var strength_texture = GradientTexture2D.new()

var spectrogram_img = Image.create(512, 512, false, Image.FORMAT_RGBA8)
var spectrogram_texture = ImageTexture.create_from_image(spectrogram_img)
var spectrogram_timer = Timer.new()

func _ready():
	add_child(static_player)
	static_player.bus = "RadioStatic"
	static_player.stream = STATIC
	static_player.play()
	static_player.volume_db = STATIC_VOLUME
	spectrogram_img.fill(GRADIENT_SPECTROGRAM.sample(0.0))
	add_child(spectrogram_timer)
	spectrogram_timer.wait_time = 0.016
	spectrogram_timer.timeout.connect(update_spectrogram)
	spectrogram_timer.start()
	
func input_update(event):
	if frequency < 0.999 and event.is_action_pressed("tune_up"):
		if Input.is_action_pressed("tune_modifiy"):
			DESIRED_FREQUENCY += 0.010
		else:
			DESIRED_FREQUENCY += 0.002
		static_player.play()
		static_player.seek(randf_range(0.0, 10.0))
	if frequency > 0.001 and event.is_action_pressed("tune_down"):
		if Input.is_action_pressed("tune_modifiy"):
			DESIRED_FREQUENCY -= 0.010
		else:
			DESIRED_FREQUENCY -= 0.002
		static_player.play()
		static_player.seek(randf_range(0.0, 10.0))
		
	if event.is_action_pressed("tune_up_large", true):
		DESIRED_FREQUENCY += 0.1
	if event.is_action_pressed("tune_down_large", true):
		DESIRED_FREQUENCY -= 0.1
	
	if Input.is_key_pressed(KEY_1):
		DESIRED_FREQUENCY = 0.1
	if Input.is_key_pressed(KEY_2):
		DESIRED_FREQUENCY = 0.2
	if Input.is_key_pressed(KEY_3):
		DESIRED_FREQUENCY = 0.3
	if Input.is_key_pressed(KEY_4):
		DESIRED_FREQUENCY = 0.4
	if Input.is_key_pressed(KEY_5):
		DESIRED_FREQUENCY = 0.5
	if Input.is_key_pressed(KEY_6):
		DESIRED_FREQUENCY = 0.6
	if Input.is_key_pressed(KEY_7):
		DESIRED_FREQUENCY = 0.7
	if Input.is_key_pressed(KEY_8):
		DESIRED_FREQUENCY = 0.8
	if Input.is_key_pressed(KEY_9):
		DESIRED_FREQUENCY = 0.9
		
	DESIRED_FREQUENCY = clamp(DESIRED_FREQUENCY, 0.0, 1.0)
	
	if event.is_action_released("tune_modifiy") or event.is_action_released("tune_up_large") or event.is_action_released("tune_down_large"):
		DESIRED_FREQUENCY = frequency
		
func update(delta):
	frequency = lerpf(frequency, DESIRED_FREQUENCY, delta * 4)
	update_visuals(delta)
	reciever_signal_strength = 0.0
	find_signals()
	static_player.volume_db = remap(reciever_signal_strength, 0.0, 1.0, STATIC_VOLUME, -50.0)
	Global.frequency = frequency
	Global.signal_strength = reciever_signal_strength

func find_signals():
	if signal_manager == null:
		push_error("Signal manager not found!")
		return
	for sig in signal_manager.get_children():
		if sig is SignalTransmitter:
			var signal_strength = sig.get_signal_strength(global_position, frequency)
			reciever_signal_strength += signal_strength #Set total combined signal strength for visual effects
			sig.update_strength(signal_strength)
					
func update_visuals(_delta):
	var strength = reciever_signal_strength
	ANIM_TREE["parameters/TimeSeek/seek_request"] = remap(frequency, 0.0, 1.0, 0.0, 1.25)
	MAT_OSC.set_shader_parameter("freq", frequency * 40)
	MAT_STRENGTH_IND.set_shader_parameter("emission", GRADIENT_STRENGTH.sample(strength))
	MAT_STRENGTH_IND.set_shader_parameter("emission_energy", radio_bus_listener.get_magnitude_for_frequency_range(0, 10000).length() * 64)
	MAT_AUDIO_IND.set_shader_parameter("emission_energy", radio_bus_listener.get_magnitude_for_frequency_range(0, 10000).length() * 20)
	MAT_AUDIO_IND.set_shader_parameter("texture_albedo", spectrogram_texture)
	MAT_SPECTROGRAM.set_shader_parameter("texture_albedo", spectrogram_texture)
	MAT_SPECTROGRAM.set_shader_parameter("texture_emission", spectrogram_texture)

func update_spectrogram():
	var height = spectrogram_img.get_height()
	var tempImg = Image.new()
	tempImg.copy_from(spectrogram_img)
	spectrogram_img.blit_rect(tempImg, Rect2(0, 0, spectrogram_img.get_width() - 1, height), Vector2(1,0))
	var hz_segment = 16000 / height
	var hz_prev = 0
	for i in height:
		var hz_current = hz_prev + hz_segment
		hz_prev = hz_current
		spectrogram_img.set_pixel(0, height - i - 1, GRADIENT_SPECTROGRAM.sample(1000 * radio_bus_listener.get_magnitude_for_frequency_range(hz_prev, hz_current).length()))
	spectrogram_texture = ImageTexture.create_from_image(spectrogram_img)

func deploy():
	super()
	static_player.play()
	AudioServer.set_bus_volume_db(2, RADIO_VOLUME)

func holster():
	super()
	static_player.stop()
	AudioServer.set_bus_volume_db(2, -40.0)
