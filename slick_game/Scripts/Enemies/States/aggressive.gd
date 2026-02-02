extends State


signal ready_weapons


@onready var state_machine = get_parent()

## Virtual function
## Called upon state entering StateMachine
func enter() -> void:
	ready_weapons.emit()
	set_nav_target()

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
	if parent.check_target_reached(parent.player_target.global_position):
		parent.nav_agent.target_reached.emit()

func set_nav_target() -> void:
	var target_pos = parent.player_target.global_position
	if target_pos.distance_to(parent.global_position) > parent.max_attack_margin:
		var direction = (parent.global_position - target_pos).normalized()
		target_pos -= direction * parent.max_attack_margin
	elif target_pos.distance_to(parent.global_position) < parent.min_attack_margin:
		var direction = (target_pos - parent.global_position).normalized()
		target_pos += direction * parent.min_attack_margin

## Virtual function
## Called for pathfinding states
func target_reached() -> void:
	if (
		parent.distance_to_player() > parent.max_attack_margin
		or 
		parent.distance_to_player() < parent.min_attack_margin
		):
		set_nav_target()
	else:
		state_machine.change_state($"../Attack")
