class_name  ToggleableComponent
extends InteractableComponent

signal toggled_on
signal toggled_off

@export var TOGGLED = false

func interact(interacter):
	if LOCKED:
		emit_signal("interacted_locked", interacter)
	else:
		if TOGGLED:
			TOGGLED = false
			emit_signal("toggled_off")
		else:
			TOGGLED = true
			emit_signal("toggled_on")
