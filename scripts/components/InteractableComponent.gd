@icon("res://assets/ui/editor/icons/click.svg")
class_name InteractableComponent
extends Node

signal interacted ##Emitted when the object is interacted with
signal interacted_locked ##Emitted when the object is interacted while it is locked

@export var ENABLED = true ##Should interactable start enabled
@export var LOCKED = false ##Should interactable be locked (locked interactables emit a different signal when interacted with)
@export var COOLDOWN : float = 0.2 ##Cooldown until interactable can be interacted with again (if set to zero this is disabled)

@onready var timer = Timer.new()

func _ready():
	get_parent().set_collision_layer_value(3, true)
	if COOLDOWN > 0.0:
		add_child(timer)
		timer.autostart = false
		timer.wait_time = COOLDOWN
		timer.timeout.connect(enable)
	else:
		timer.queue_free()

func _enter_tree() -> void:
	get_parent().set_meta(&"InteractableComponent", self)
	
func _exit_tree() -> void:
	get_parent().remove_meta(&"InteractableComponent")

func interact(interactor):
	if ENABLED:
		if COOLDOWN > 0.0:
			ENABLED = false
			timer.start()
		if LOCKED:
			emit_signal("interacted_locked", interactor)
		else:
			emit_signal("interacted", interactor)
			
func enable():
	ENABLED = true
