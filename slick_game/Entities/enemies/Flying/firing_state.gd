extends State


@onready var state_machine = get_parent()
const PROJECTILE_SCENE = preload("res://Entities/Projectiles/ranged enemy projectile.tscn")
@onready var animation_player = $"../../AnimationPlayer"


## Virtual function
## Called upon state entering StateMachine
func enter() -> void:
	animation_player.play("Fire")

## Virtual function
## Called upon state exiting State Machine
func exit() -> void:
	parent.flying = true

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


func fire_projectile() -> void:
	var origin = get_parent()
	var projectile = PROJECTILE_SCENE.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = origin.global_position
	projectile.global_rotation = get_parent().global_rotation


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	state_machine.change_state($"../Flying")
