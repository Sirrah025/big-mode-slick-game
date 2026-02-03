extends State


signal ready_weapons


var Idle_Path_Pos

@onready var state_machine = get_parent()

@onready var vision_raycasts = %Vision.get_children()

## Virtual function
## Called upon state entering StateMachine
func enter() -> void:
	Idle_Path_Pos = parent.nav_agent.target_position

## Virtual function
## Called upon state exiting State Machine
func exit() -> void:
	ready_weapons.emit()

## Virtual function
## Called within _process
## var delta: delta from _process
func update(delta) -> void:
	for vision_raycast in vision_raycasts:
		if vision_raycast.is_colliding():
			_activate_aggression()

## Virtual function
## Called within _physics_process
## var delta: delta from _physics_process
func physics_update(delta) -> void:
	pass

## Virtual function
## Called for pathfinding states
func target_reached() -> void:
	# Cycle to next point on path
	parent.Idle_Targets_index += 1
	# Reset index if it equals or exceeds point count
	if parent.Idle_Targets_index >= parent.Idle_Path_Curve.point_count:
		parent.Idle_Targets_index = 0
	print_debug("We are at index " + str(parent.Idle_Targets_index))
	# Grab next point
	Idle_Path_Pos = parent.Idle_Path_Curve.get_point_position(parent.Idle_Targets_index)
	print_debug("We are targeting position  " + str(Idle_Path_Pos))
	print_debug("Our current position is " + str(parent.global_position)) 
	# Set target_position to new position on idle path
	parent.set_new_idle_target_pos()

func _activate_aggression() -> void:
	print_debug("We are aggressive now")
	state_machine.change_state($"../Aggressive")
