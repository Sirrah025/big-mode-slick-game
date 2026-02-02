extends State


@onready var state_machine = get_parent()


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
	# during Idle State 
	var Idle_Path_Pos = parent.Idle_Path_Curve.get_point_position(parent.Idle_Targets_index)
	
	parent.nav_agent.target_position = Idle_Path_Pos
	
	if parent.check_target_reached(Idle_Path_Pos):
		parent.nav_agent.target_reached.emit()
	
	if activated_by_player():
		state_machine.change_state($"../Aggressive")

## Virtual function
## Called for pathfinding states
func target_reached() -> void:
	# Cycle to next point on path
	parent.Idle_Targets_index += 1
	# Reset index if it equals or exceeds point count
	if parent.Idle_Targets_index >= parent.Idle_Path_Curve.point_count:
		parent.Idle_Targets_index = 0

func activated_by_player() -> bool:
	if (
		parent.player_target.global_position.distance_to(parent.global_position) < parent.activation_margin
	):
		return true
	return false
