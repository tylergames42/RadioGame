@icon("res://assets/ui/editor/icons/gun_pickup.svg")
class_name WeaponCollectable
extends PhysicsProp

@export var weapon : PackedScene

func _on_interactable_component_interacted(interactor):
	if interactor.weapon_manager != null:
		interactor.weapon_manager.add_weapon(weapon)
		queue_free()
