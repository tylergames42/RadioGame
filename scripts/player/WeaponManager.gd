class_name WeaponManager
extends Node3D

@export var PLAYER : RigidBody3D

var active_weapon : WeaponBase

func add_weapon(weapon : PackedScene) -> void:
	for child in get_children():
		if child is WeaponBase:
			if active_weapon != null and active_weapon.WEAPON_NAME == child.WEAPON_NAME:
				return
	var new_weapon = weapon.instantiate()
	add_child(new_weapon)
	swap_to_weapon(new_weapon.WEAPON_NAME)
	print("ADDED " + new_weapon.WEAPON_NAME)

func swap_to_weapon(weapon_name : String) -> void:
	for child in get_children():
		if child is WeaponBase:
			if weapon_name == child.WEAPON_NAME:
				if active_weapon != null:
					active_weapon.holster()
				active_weapon = child
				active_weapon.draw()

func _process(delta):
	if active_weapon == null:
		return
	active_weapon.update(delta)
	view_sway(delta)
	
func _physics_process(delta):
	if active_weapon == null:
		return
	active_weapon.physics_update(delta)
	
func _input(event):
	if active_weapon == null:
		return
	active_weapon.input_update(event)
	
func view_sway(delta) -> void:
	rotation.y = lerp(rotation.y, -PLAYER.linear_velocity.y * 0.01, 10 * delta)
	rotation.z = lerp(rotation.x, (PLAYER.linear_velocity.x + PLAYER.linear_velocity.z) * 0.01, 10 * delta)
