extends CharacterBody3D

@export_category("Attack Parameters")
@export var min_attack_margin: = 0.0
@export var max_attack_margin: float


@export_category("Movement Data")
@export var speed = 5.0
@export var turn_speed = 4.0
@export var Idle_Path: Path3D
@onready var Idle_Path_Curve = Idle_Path.get_curve()
var Idle_Targets_index: int


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
	set_new_idle_target_pos()


func _physics_process(delta: float) -> void:
	Aggression_State_Machine.current_state.physics_update(delta)
	movement(delta)


func movement(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		print_debug("Skipping to next frame")
		await get_tree().physics_frame
	# We grab destination and subtract our global_position from it
	if nav_agent.target_position == global_position:
		velocity = global_position
		look_at_target(player_target.global_position)
	else: 
		var destination = nav_agent.get_next_path_position()
		var target_vector = destination - global_transform.origin
		# if local_destination.length_squared() > 1.0:
		target_vector = target_vector.normalized() * speed
		# We set velocity
		velocity = target_vector
		#velocity = velocity.move_toward(velocity, delta)
		look_at_target(destination)
	move_and_slide()

# Make model look at target
func look_at_target(target) -> void:
	if not target.is_equal_approx(global_position):
		look_at(Vector3(target.x, global_position.y, target.z), Vector3.UP)
		rotate_y(deg_to_rad(Forward_Direction.rotation.y * turn_speed)) 


# helper function
func check_target_reached(target: Vector3) -> bool:
	if min_attack_margin > 0.0 and target.distance_to(global_position) < min_attack_margin:
		return false
	if target.distance_to(global_position) <= max_attack_margin:
		return true
	return false

func check_idle_target_reached(target: Vector3) -> bool:
	if target.distance_to(global_position) < 2.1:
		return true
	return false

func set_new_idle_target_pos() -> void:
	print_debug("We have set a new position")
	nav_agent.target_position = Idle_Path_Curve.get_point_position(Idle_Targets_index)

# Another helper function for common calls to distance to player
func distance_to_player() -> float:
	return player_target.global_position.distance_to(global_position)


func _on_entity_died() -> void:
	queue_free()


func _on_navigation_agent_3d_navigation_finished() -> void:
	print_debug("We reached Target!")
	Aggression_State_Machine.current_state.target_reached()
