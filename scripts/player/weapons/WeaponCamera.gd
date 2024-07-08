extends WeaponBase

@export var VIEW_FADE : ColorRect
@export var CAMERA_MESH : MeshInstance3D
@export var CAMERA_CAM : Camera3D
@export var CAMERA_UI : Control
@export var CAMERA_EFFECTS : Control
@export var CAMERA_FLASH : Light3D
#@export var CAMERA_UI_FLASH
@export_group("Audio")
@export var SHOOT_SFX : AudioStream
@export var SHOOT_FLASH_SFX : AudioStream
@export var ZOOM_IN_SFX : AudioStream
@export var ZOOM_OUT_SFX : AudioStream

@onready var audio_player = AudioStreamPlayer3D.new()

var player_camera
var in_camera_view : bool = false
var flash_enabled : bool = true
var desired_zoom : float

func _ready():
	add_child(audio_player)
	player_camera = get_viewport().get_camera_3d()
	desired_zoom = CAMERA_CAM.fov
	CAMERA_FLASH.light_energy = 0.0
	CAMERA_UI.hide()
	CAMERA_EFFECTS.hide()

func input_update(event):
	if event.is_action_pressed("fire_alt"):
		if in_camera_view:
			close_camera_view()
		else:
			open_camera_view()
	
	if !in_camera_view:
		return
	
	if event.is_action_pressed("fire_main"):
		take_picture()
			
	if event.is_action_pressed("flashlight"):
		if flash_enabled:
			$Camera3D/CameraUI/FlashIndicator.texture = load("res://assets/ui/camera/ui_flash_off.svg")
			flash_enabled = false
		else:
			$Camera3D/CameraUI/FlashIndicator.texture = load("res://assets/ui/camera/ui_flash_on.svg")
			flash_enabled = true
	
	if event.is_action_pressed("tune_up"):
		if !audio_player.playing:
			audio_player.stream = ZOOM_OUT_SFX
			audio_player.play()
		if Input.is_action_pressed("tune_modifiy"):
			desired_zoom -= 2.5
		else:
			desired_zoom -= 1.0
		desired_zoom = clamp(desired_zoom, 16.0, 60.0)
		$Camera3D/CameraUI/HSlider.value = CAMERA_CAM.fov
			
	if event.is_action_pressed("tune_down"):
		if !audio_player.playing:
			audio_player.stream = ZOOM_IN_SFX
			audio_player.play()
		if Input.is_action_pressed("tune_modifiy"):
			desired_zoom += 2.5
		else:
			desired_zoom += 1.0
		desired_zoom = clamp(desired_zoom, 16.0, 60.0)
		$Camera3D/CameraUI/HSlider.value = CAMERA_CAM.fov
	
func update(delta):
	VIEW_FADE.color.a = lerpf(VIEW_FADE.color.a, 0, delta * 4.0)
	CAMERA_CAM.fov = lerpf(CAMERA_CAM.fov, desired_zoom, delta * 4.0)
	CAMERA_FLASH.light_energy = lerpf(CAMERA_FLASH.light_energy, 0.0, delta * 1.4)

func take_picture():
	CAMERA_UI.hide()
	Global.player.ui.hide()
	audio_player.stream = SHOOT_SFX
	if flash_enabled:
		audio_player.stream = SHOOT_FLASH_SFX
		CAMERA_FLASH.light_energy = 6.0
	audio_player.play()
	await get_tree().create_timer(0.1).timeout
	var capture = get_viewport().get_texture().get_image()
	var filename = "res://screenshot_test.png"
	capture.save_png(filename)
	CAMERA_UI.show()
	
func open_camera_view():
	ANIM_TREE["parameters/StateMachine/playback"].travel("view_enter")
	await ANIM_TREE.animation_finished
	VIEW_FADE.color.a = 1.0
	Global.player.ui.hide()
	CAMERA_UI.show()
	CAMERA_EFFECTS.show()
	CAMERA_CAM.make_current()
	in_camera_view = true
	
func close_camera_view():
	ANIM_TREE["parameters/StateMachine/playback"].travel("view_exit")
	VIEW_FADE.color.a = 1.0
	Global.player.ui.show()
	CAMERA_UI.hide()
	CAMERA_EFFECTS.hide()
	player_camera.make_current()
	in_camera_view = false
	
func holster():
	close_camera_view()
	VIEW_FADE.color.a = 0.0
	CAMERA_FLASH.light_energy = 0.0
	super()
