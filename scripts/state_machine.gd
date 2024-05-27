class_name StateMachine

extends Node

@export var CURRENT_STATE : State ##State to start in
@export var DEBUG : bool = false ##Debug tool to show state transitions in console
var states: Dictionary = {}

var last_state : State = CURRENT_STATE #TESTING

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
			
	await owner.ready
	CURRENT_STATE.enter(CURRENT_STATE.name)
	last_state = CURRENT_STATE #TESTING

func _process(delta):
	CURRENT_STATE.update(delta)
	Global.debug_gui.state = CURRENT_STATE
	
func _physics_process(delta):
	CURRENT_STATE.physics_update(delta)
	
func _input(event):
	CURRENT_STATE.input_update(event)

func on_child_transition(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter(CURRENT_STATE.name)
			if DEBUG:
				print(CURRENT_STATE.to_string() + " > " + new_state.to_string())
			last_state = CURRENT_STATE #TESTING
			CURRENT_STATE = new_state
	else:
		push_error("Invalid state name!")
