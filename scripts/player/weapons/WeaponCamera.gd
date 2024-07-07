extends WeaponBase

@export var CAMERA_MESH : MeshInstance3D
@export var CAMERA_UI : Control
@export var CAMERA_FLASH : Light3D
@export var CAMERA_ENVIRONMENT : Environment
@export var CAMERA_ATTRIBUTES : CameraAttributesPhysical
#@export var CAMERA_UI_FLASH
@export_group("Audio")
@export var SHOOT_SFX : AudioStream
@export var SHOOT_FLASH_SFX : AudioStream
@export var ZOOM_IN_SFX : AudioStream
@export var ZOOM_OUT_SFX : AudioStream

@onready var audio_player = AudioStreamPlayer3D.new()

var player_camera
var player_camera_fov
var player_camera_environment
var player_camera_attributes
var in_camera_view : bool = false
var flash_enabled : bool = true

func _ready():
	add_child(audio_player)
	player_camera = get_viewport().get_camera_3d()
	player_camera_fov = player_camera.fov
	player_camera_environment = player_camera.environment
	player_camera_attributes = player_camera.attributes
	CAMERA_FLASH.light_energy = 0.0
	CAMERA_UI.hide()

func input_update(event):
	if event.is_action_pressed("fire_main"):
		CAMERA_MESH.hide()
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
		if !in_camera_view:
			CAMERA_MESH.show()
			Global.player.ui.show()
			
	if event.is_action_pressed("fire_alt"):
		if in_camera_view:
			player_camera.environment = player_camera_environment
			player_camera.attributes = player_camera_attributes
			player_camera.fov = player_camera_fov
			CAMERA_MESH.show()
			Global.player.ui.show()
			in_camera_view = false
		else:
			player_camera.environment = CAMERA_ENVIRONMENT
			player_camera.attributes = CAMERA_ATTRIBUTES
			CAMERA_MESH.hide()
			Global.player.ui.hide()
			in_camera_view = true
			
	if event.is_action_pressed("flashlight"):
		if flash_enabled:
			$CameraUI/FlashIndicator.texture = load("res://assets/ui/camera/ui_flash_off.svg")
			flash_enabled = false
		else:
			$CameraUI/FlashIndicator.texture = load("res://assets/ui/camera/ui_flash_on.svg")
			flash_enabled = true
	
	if event.is_action_pressed("tune_up"):
		if Input.is_action_pressed("tune_modifiy"):
			CAMERA_ATTRIBUTES.frustum_focal_length += 2.5
		else:
			CAMERA_ATTRIBUTES.frustum_focal_length += 0.5
		CAMERA_ATTRIBUTES.frustum_focal_length = clamp(CAMERA_ATTRIBUTES.frustum_focal_length, 16.0, 60.0)
		$CameraUI/HSlider.value = CAMERA_ATTRIBUTES.frustum_focal_length
			
	if event.is_action_pressed("tune_down"):
		if Input.is_action_pressed("tune_modifiy"):
			CAMERA_ATTRIBUTES.frustum_focal_length -= 2.5
		else:
			CAMERA_ATTRIBUTES.frustum_focal_length -= 0.5
		CAMERA_ATTRIBUTES.frustum_focal_length = clamp(CAMERA_ATTRIBUTES.frustum_focal_length, 16.0, 60.0)
		$CameraUI/HSlider.value = CAMERA_ATTRIBUTES.frustum_focal_length
	
func update(delta):
	CAMERA_FLASH.light_energy = lerpf(CAMERA_FLASH.light_energy, 0.0, 1.4 * delta)
