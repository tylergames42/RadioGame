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
	#Setup cooldown timer
	if COOLDOWN > 0.0:
		add_child(timer)
		timer.autostart = false
		timer.wait_time = COOLDOWN
		timer.timeout.connect(enable)
	else: #Remove timer if not needed
		timer.queue_free()

func _enter_tree() -> void:
	var parent = get_parent()
	parent.set_meta(&"InteractableComponent", self)
	parent.set_collision_layer_value(3, true)
	#Connect signals
	if parent.has_method("_on_interactable_component_interacted"):
		if !interacted.is_connected(parent._on_interactable_component_interacted):
			interacted.connect(parent._on_interactable_component_interacted)
	if parent.has_method("_on_interactable_component_interacted_locked"):
		if !interacted_locked.is_connected(parent._on_interactable_component_interacted_locked):
			interacted_locked.connect(parent._on_interactable_component_interacted_locked)
	
func _exit_tree() -> void:
	var parent = get_parent()
	parent.remove_meta(&"InteractableComponent")
	parent.set_collision_layer_value(3, false)
	#Disconnect signals
	if parent.has_method("_on_interactable_component_interacted"):
		if !interacted.is_connected(parent._on_interactable_component_interacted):
			interacted.disconnect(parent._on_interactable_component_interacted)
	if parent.has_method("_on_interactable_component_interacted_locked"):
		if !interacted_locked.is_connected(parent._on_interactable_component_interacted_locked):
			interacted_locked.disconnect(parent._on_interactable_component_interacted_locked)

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
