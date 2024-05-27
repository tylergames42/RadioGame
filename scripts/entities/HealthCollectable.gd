@icon("res://assets/ui/editor/icons/health.svg")
class_name HealthCollectable
extends PhysicsProp

@export var HEAL_AMOUNT : int = 10

func _on_interactable_component_interacted(interacter):
	if interacter.has_meta("HealthComponent") and interacter.get_meta("HealthComponent").health < interacter.get_meta("HealthComponent").MAX_HEALTH:
		interacter.get_meta("HealthComponent").heal(HEAL_AMOUNT)
		queue_free()
	else:
		holder = interacter
		if held:
			drop()
		else:
			carry()
