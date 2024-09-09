@icon("res://assets/ui/editor/icons/heart.svg")
class_name HealthComponent
extends Node

signal hurt
signal killed

@export var MAX_HEALTH : int = 100 ##Maximum amount of health
@export var STARTING_HEALTH : int = 100 ##Amount of health to start with

var health : int

func _enter_tree() -> void:
	var parent = get_parent()
	parent.set_meta(&"HealthComponent", self)
	#Connect signals
	if parent.has_method("_on_health_component_hurt"):
		if !hurt.is_connected(parent._on_health_component_hurt):
			hurt.connect(parent._on_health_component_hurt)
	if parent.has_method("_on_health_component_killed"):
		if !killed.is_connected(parent._on_health_component_killed):
			killed.connect(parent._on_health_component_killed)
	
func _exit_tree() -> void:
	var parent = get_parent()
	parent.remove_meta(&"HealthComponent")
	#Disconnect signals
	if parent.has_method("_on_health_component_hurt"):
		if !hurt.is_connected(parent._on_health_component_hurt):
			hurt.connect(parent._on_health_component_hurt)
	if parent.has_method("_on_health_component_killed"):
		if !killed.is_connected(parent._on_health_component_killed):
			killed.connect(parent._on_health_component_killed)

func _ready():
	health = STARTING_HEALTH

func heal(amount: int):
	health += amount
	if health > MAX_HEALTH:
		health = MAX_HEALTH

func damage(amount: int):
	health -= amount
	emit_signal("hurt", amount)
	if health <= 0:
		emit_signal("killed")
		health = 0
