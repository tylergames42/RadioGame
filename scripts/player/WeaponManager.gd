class_name WeaponManager
extends Node3D

@export var PLAYER : RigidBody3D

var active_weapon : WeaponBase
var input_enabled : bool = true

func add_weapon(weapon : PackedScene) -> void:
	var new_weapon = weapon.instantiate()
	for child in get_children(): #Don't give duplicate weapons
		if child is WeaponBase:
			if child.WEAPON_NAME == new_weapon.WEAPON_NAME:
				swap_to_weapon(child.WEAPON_NAME)
				new_weapon.queue_free()
				return
	add_child(new_weapon)
	if active_weapon != null:
		active_weapon.holster()
	active_weapon = new_weapon
	new_weapon.pickup()

func swap_to_weapon(weapon_name : String) -> void:
	if weapon_name == "null":
		if active_weapon != null:
					active_weapon.holster()
		active_weapon = null
	if active_weapon != null:
		if active_weapon.WEAPON_NAME == weapon_name:
			deploy_active()
			return
	for child in get_children():
		if child is WeaponBase:
			if weapon_name == child.WEAPON_NAME:
				if active_weapon != null:
					active_weapon.holster()
				active_weapon = child
				active_weapon.deploy()
				
func drop_weapon(weapon_name : String) -> void:
	for child in get_children():
		if child is WeaponBase:
			if weapon_name == child.WEAPON_NAME:
				if weapon_name == active_weapon.WEAPON_NAME:
					active_weapon.holster()
				child.queue_free()
	
func deploy_active():
	if active_weapon != null:
		active_weapon.deploy()
		
func holster_active():
	if active_weapon != null:
		active_weapon.holster()

func _process(delta):
	if active_weapon == null:
		return
	if active_weapon.active:
		active_weapon.update(delta)
		view_sway(delta)
	
func _physics_process(delta):
	if active_weapon == null:
		return
	if active_weapon.active:
		active_weapon.physics_update(delta)
	
func _input(event):
	if active_weapon == null:
		return
	if !input_enabled:
		return
	if active_weapon.active:
		active_weapon.input_update(event)
	
	if event.is_action_pressed("ui_right"):
		swap_to_weapon("Camera")
	if event.is_action_pressed("ui_left"):
		swap_to_weapon("Radio")
	
func view_sway(delta) -> void:
	rotation.y = lerp(rotation.y, -PLAYER.prev_velocity.y * 0.01, 10 * delta)
	rotation.z = lerp(rotation.x, (PLAYER.prev_velocity.x + PLAYER.prev_velocity.z) * 0.01, 10 * delta)
