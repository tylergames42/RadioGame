extends RigidBody3D

@export_category("Player")
@export_group("Visuals")
@export_range(0.01, 0.1) var VIEW_TILT_MULTIPLIER : float = 0.01
@export_group("Controls")
@export var TOGGLE_CROUCH : bool = false ##If crouching should be a toggle
@export var TOGGLE_SPRINT : bool = false ##If sprinting should be a toggle
@export_range(0.01, 1.0) var MOUSE_SENSITIVITY_HORIZONTAL : float = 0.3 ##Mouse sensitivity on X axis
@export_range(0.01, 1.0) var MOUSE_SENSITIVITY_VERTICAL : float = 0.3 ##Mouse sensitivity on Y axis
@export_group("Movement:")
@export var MAX_STEP_HEIGHT : float = 0.5 ##Maximum distance the player can step up / down
@export var MAX_SLOPE_ANGLE : float = 44 ##Maximum angle slope the player can go up before sliding down it (I think this shit is broken, just keep it at 44)
@export var AIR_CONTROL_MULTIPLIER : float = 0.1 ##Multiplier to player input in air

@onready var collider = $Collider #Player collider
@onready var root = $Root #Root of character (this rotates horizontally)
@onready var head = $Root/Head #Character head (this rotates vertically)
@onready var camera = $Root/Head/Camera
@onready var headcast = $headcast  #Shapecast to check if can uncrouch
@onready var groundcast = $groundcast #Shapecast to check if grounded
@onready var interactcast = $Root/Head/interactcast #Raycast to do interaction checks
@onready var hold_point = $Root/Head/hold_point #Point at which to position held objects
@onready var animation_player = $AnimationPlayer #Animation player
@onready var state_machine = $PlayerStateMachine #State machine for player
@onready var weapon_manager = $Root/Head/WeaponManager
@onready var flashlight = $Root/Head/Flashlight
@onready var leg_anim_player = $Root/legs_test/AnimationPlayer

@onready var AudioPlayer = SpatialAudioPlayer3D.new() #Audio player for footsteps, jump sounds, etc.

var grounded : bool = false
var can_climb : bool = true
var current_speed : float
var held_object : PhysicsProp
var control_multiplier : float = 1.0
var direction : Vector3
var input_dir : Vector3
var target_velocity : Vector3

var was_grounded : bool = false

func _ready():
	Global.player = self
	current_speed = 0.0
	
	add_child(AudioPlayer)

func _input(event):
	if event.is_action_pressed("interact"):
		if held_object != null: #If holding an object drop it
			held_object.drop()
		else:
			interact()
		
	if event.is_action_pressed("fire_main"):
		if held_object != null: #If holding an object throw it
			var throw_vector = -head.global_transform.basis.z
			held_object.throw(throw_vector)
		
	if event.is_action_pressed("noclip"):
		if state_machine.CURRENT_STATE.name != "PlayerNoclipState":
			state_machine.on_child_transition("PlayerNoclipState")
		else:
			state_machine.on_child_transition("PlayerIdleState")
		
	if event.is_action_pressed("flashlight"):
		if flashlight.visible:
			flashlight.visible = false
		else:
			flashlight.visible = true
	
	if event is InputEventMouseMotion: #Get mouse input
		root.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY_HORIZONTAL))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY_VERTICAL))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
			
	#Set input direction vector
	input_dir = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0.0,
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward"))
	direction = root.transform.basis * input_dir.normalized()

func _physics_process(delta):
	was_grounded = grounded
	grounded = groundcast.is_colliding() #Get if on ground
	
	if grounded && groundcast.get_collider(0) == held_object: #Prevent holding stood on objects TODO: Buggy rn
		grounded = false
		held_object.drop()
	
	if grounded:
		control_multiplier = 1
	else:
		control_multiplier = AIR_CONTROL_MULTIPLIER
		
	target_velocity = direction * current_speed
	var impulse_vector = target_velocity - Vector3(linear_velocity.x,0,linear_velocity.z)
	apply_central_impulse(impulse_vector * control_multiplier)
	
	camera_tilt(delta)

func slopeSliding():
	var normal_average = Vector3.ZERO
	if grounded:
		for collision in groundcast.get_collision_count(): #Get average normal of floor stood on
			if not is_zero_approx(groundcast.get_collision_normal(collision).y):
				normal_average = groundcast.get_collision_normal(collision)
		normal_average /= groundcast.get_collision_count()
		var slide_normal = Vector3(normal_average.x, -1, normal_average.z).normalized() #Vector to slide down
		#DebugDraw3D.draw_arrow_ray(position, slide_normal, 3.0, Color(255,0,0))
		
		if slide_normal.dot(Vector3.DOWN) <= deg_to_rad(90 - MAX_SLOPE_ANGLE): #Check if slope is too steep
			apply_central_impulse(slide_normal * (current_speed * 0.6))
			can_climb = false
		else:
			can_climb = true

func stair_step_down():
	# If we're falling from a step
	if was_grounded and can_climb:
		# Initialize body test variables
		var body_test_params = PhysicsTestMotionParameters3D.new()
		var body_test_result = PhysicsTestMotionResult3D.new()

		body_test_params.from = self.global_transform	## We get the player's current global_transform
		body_test_params.motion = Vector3(0, -MAX_STEP_HEIGHT, 0)	## We project the player downward

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			global_position.y += body_test_result.get_travel().y
			grounded = true

func stair_step_up():
	if !can_climb or !grounded:
		return
		
	if headcast.is_colliding():
		return
	
	# 0. Initialize testing variables
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform				## Storing current global_transform for testing
	var distance = direction * 0.1						## Distance forward we want to check
	body_test_params.from = self.global_transform		## Self as origin point
	body_test_params.motion = distance					## Go forward by current distance

	# Pre-check: Are we colliding?
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		## If we don't collide, return
		return

	# 1. Move test_transform to collision location
	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	# 2. Move test_transform up to ceiling (if any)
	var step_up = MAX_STEP_HEIGHT * Vector3.UP
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3.5 Project remaining along wall normal (if any)
	## So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = direction.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (direction - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

	# 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_HEIGHT * -Vector3.UP

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return

	test_transform = test_transform.translated(body_test_result.get_travel())

	# 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()
	var temp_floor_max_angle = deg_to_rad(MAX_SLOPE_ANGLE)
	if (snappedf(surface_normal.angle_to(Vector3.UP), 0.001) > temp_floor_max_angle):
		return

	# 6. Move player up
	var global_pos = global_position
	var step_up_dist = test_transform.origin.y - global_pos.y

	global_pos.y = test_transform.origin.y
	global_pos.x += direction.x * 0.05
	global_pos.z += direction.z * 0.05
	global_position = global_pos

func interact():
	if interactcast.is_colliding():
		var interacted_object = interactcast.get_collider()
		if interacted_object.has_meta("InteractableComponent"):
			interacted_object.get_meta("InteractableComponent", null).interact(self)

func play_step_sfx():
	if grounded:
		var material = load("res://assets/material_properties/mat_default.tres")
		var ground = groundcast.get_collider(0)
		if "physics_material_override" in ground:
			if ground.physics_material_override is MaterialProperties:
				if ground.physics_material_override.SFX_STEP != null:
					material = ground.physics_material_override
		AudioPlayer.stream = material.SFX_STEP
		AudioPlayer.spatial_play()
		
func camera_tilt(delta):
	camera.rotation.z = lerp(camera.rotation.z, -input_dir.x * VIEW_TILT_MULTIPLIER, 10 * delta)
