@icon("res://assets/ui/editor/icons/heart.svg")
class_name HealthComponent
extends Node

signal hurt
signal killed

@export var MAX_HEALTH : int = 100 ##Maximum amount of health
@export var STARTING_HEALTH : int = 100 ##Amount of health to start with

var health : int

func _enter_tree() -> void:
	get_parent().set_meta(&"HealthComponent", self)
	
func _exit_tree() -> void:
	get_parent().remove_meta(&"HealthComponent")

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
