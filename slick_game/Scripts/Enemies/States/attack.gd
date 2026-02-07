extends State


signal fire_weapons

@onready var state_machine = get_parent()
@onready var reaction_timer := %"Reaction Timer"

## Virtual function
## Called upon state entering StateMachine
func enter() -> void:
	parent.velocity = Vector3.ZERO
	fire_weapon()

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


func _on_fire_animation_finished() -> void: 
	reaction_timer.start()


func _on_reaction_timer_timeout() -> void:
	if parent.distance_to_player() <= parent.max_attack_margin:
		fire_weapon()
	else:
		state_machine.change_state($"../Aggressive")
