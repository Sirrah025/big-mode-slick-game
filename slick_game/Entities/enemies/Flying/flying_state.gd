extends State


@onready var state_machine = get_parent()

## Virtual function
## Called upon state entering StateMachine
func enter() -> void:
	pass

## Virtual function
## Called upon state exiting State Machine
func exit() -> void:
	parent.flying = false
	parent.target_pos = null

## Virtual function
## Called within _process
## var delta: delta from _process
func update(delta) -> void:
	if parent.global_position == parent.target_pos:
		state_machine.change_state($"../Firing")

## Virtual function
## Called within _physics_process
## var delta: delta from _physics_process
func physics_update(delta) -> void:
	pass

## Virtual function
## Called for pathfinding states
func target_reached() -> void:
	pass
