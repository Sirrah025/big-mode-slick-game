## Generic state machine. Initializes states and handles state transitions
## Extend class if additional functionality or data is needed for the machine
## Else, all other logics can be handled by the state class
class_name State_Machine
extends Node

signal transitioned(state)

@export var starting_state: State
var current_state: State

func init(parent: Node3D) -> void:
	for child in get_children():
		child.parent = parent
	
	change_state(starting_state)

func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()
	transitioned.emit(current_state)
