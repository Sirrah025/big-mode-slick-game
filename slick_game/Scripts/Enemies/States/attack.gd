extends State


signal fire_weapons


## Virtual function
## Called upon state entering StateMachine
func enter() -> void:
	fire_weapons.emit()

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


func fire_weapon() -> void:
	fire_weapons.emit()
