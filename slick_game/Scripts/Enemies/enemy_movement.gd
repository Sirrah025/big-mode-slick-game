extends CharacterBody3D

@export_category("Attack Parameters")
@export var min_attack_margin: = 0.0
@export var max_attack_margin: float
@export var Idle_Path: Path3D
@onready var Idle_Path_Curve = Idle_Path.get_curve()
var Idle_Targets_index: int
@export var activation_margin := 0.0


@export_category("Movement Data")
@export var speed = 5.0
@export var turn_speed = 4.0


@onready var nav_agent := $NavigationAgent3D
@onready var Aggression_State_Machine = $"Aggression State Machine"
@onready var Forward_Direction = $FaceDirection

var player_target: CharacterBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Pass self to state machine
	Aggression_State_Machine.init(self)
	# Grab player by Group
	player_target = get_tree().get_first_node_in_group("Player")
	# Set Idle Index to 0
	Idle_Targets_index = 0
	# Start idle movement if not already set
	nav_agent.target_position = Idle_Path_Curve.get_point_position(Idle_Targets_index)


func _physics_process(delta: float) -> void:
	Aggression_State_Machine.current_state.physics_update(delta)
	movement(delta)
	move_and_slide()


func movement(delta: float) -> void:
	# We grab destination and subtract our global_position from it
	await get_tree().process_frame
	var destination = nav_agent.get_next_path_position()
	var target_destination = destination - global_transform.origin
	# if local_destination.length_squared() > 1.0:
	target_destination = target_destination.normalized() * speed
	# We set velocity
	velocity = target_destination
	#velocity = velocity.move_toward(velocity, delta)
	# Make model look at target
	if not target_destination.is_equal_approx(global_position):
		look_at(Vector3(destination.x, global_position.y, destination.z), Vector3.UP)
	rotate_y(deg_to_rad(Forward_Direction.rotation.y * turn_speed)) 

# helper function
func check_target_reached(target: Vector3) -> bool:
	if min_attack_margin > 0.0 and target.distance_to(global_position) < min_attack_margin:
		return false
	if target.distance_to(global_position) <= max_attack_margin:
		return true
	return false

func distance_to_player() -> float:
	return player_target.global_position.distance_to(global_position)


func _on_navigation_agent_3d_target_reached() -> void:
	Aggression_State_Machine.current_state.target_reached()


func _on_entity_died() -> void:
	# queue_free()
	pass # Replace with function body.
