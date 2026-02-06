extends State


## Virtual function
## Called upon state entering StateMachine
func enter() -> void:
	pass

## Virtual function
## Called upon state exiting State Machine
func exit() -> void:
	pass

## Virtual function
## Called within _process
## var delta: delta from _process
func update(delta) -> void:
	pass

## Virtual function
## Called within _physics_process
## var delta: delta from _physics_process
func physics_update(delta) -> void:
	pass

## Virtual function
## Called for pathfinding states
func target_reached() -> void:
	pass
