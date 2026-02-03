extends State


@onready var state_machine = get_parent()

## Virtual function
## Called upon state entering StateMachine
func enter() -> void:
	parent.nav_agent.navigation_finished.emit()

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
		parent.nav_agent.navigation_finished.emit()

func set_nav_target() -> void:
	var target_direction 
	var target_pos = parent.player_target.global_position
	var distance = target_pos.distance_to(parent.global_position)
	if distance > parent.max_attack_margin:
		target_direction = (parent.global_position - target_pos).normalized()
		target_direction *= distance - parent.max_attack_margin
	elif distance < parent.min_attack_margin and parent.min_attack_margin > 0.0:
		target_direction = (target_pos - parent.global_position).normalized()
		target_direction *= parent.max_attack_margin - distance
	else:
		target_direction = parent.global_position
	parent.nav_agent.target_position = target_direction
	print_debug("Nav data: " + str(parent.nav_agent.target_position) + " compared to: " + str(parent.player_target.global_position))

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
		parent.nav_agent.target_position = parent.global_position
		state_machine.change_state($"../Attack")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Ready Fire":
		set_nav_target()
