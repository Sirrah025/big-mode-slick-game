extends CharacterBody3D

# --- Movement Settings ---
@export var walk_base_speed: float = 5.0 
@export var sprint_base_speed: float = 9.0 
@export var walk_force: float = 1.5
@export var sprint_force: float = 6.0
@export var max_speed: float = 24.0
@export var max_jumps: int = 2
@export var friction_low: float = 10.0
@export var friction_high: float = 5.5
@export var jump_velocity: float = 5.5
@export var air_control: float = 1.0
var jumps_left: int = max_jumps

var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

const MOUSE_SENSITIVITY: float = 0.0015

# --- Slipping ---
@export var slip_force_multiplier: float = 11.6
@export var slip_friction_multiplier: float = 0
@export var slip_steer_multiplier: float = 0.15
@export var is_sliding: bool = false

# --- Dash ---
@onready var dash_cooldown_node: Timer = $DashCooldownTimer
@onready var dash_duration_node: Timer = $DashDurationTimer
@export var dash_cooldown_time := 2.0
@export var dash_duration_time := 0.8
@export var dash_decay_multiplier := 0.95
@export var dash_force: float = 24.0

var is_dashing: bool = false
var dash_velocity: Vector3 = Vector3.ZERO
var dash_direction: Vector3 = Vector3.ZERO


# --- Camera ---
const BASE_FOV: float = 75.0
const FOV_CHANGE: float = 2.5

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/PlayerCamera

# Strafing
@export var max_tilt_angle: float = 6.0
@export var tilt_speed: float = 4.0
var current_tilt: float = 0.0 

# Head Bob
const BOB_FREQ: float = 1.6
const BOB_AMP: float = 0.09
var bob_timer: float = 0.0


# --- Runtime ---
var momentum: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	dash_duration_node.wait_time = dash_duration_time
	dash_cooldown_node.wait_time = dash_cooldown_time

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_update_momentum(delta)
	_handle_dash()
	_apply_velocity(delta)
	_update_headbob(delta)
	_update_camera_tilt(delta)
	_update_fov(delta)
	move_and_slide()

# --- Gravity ---
func _apply_gravity(delta: float) -> void:
	velocity.y = 0 if is_on_floor() else velocity.y - GRAVITY * delta

	# Reset jumps when on the floor
	if is_on_floor():
		jumps_left = max_jumps


# --- Jump ---
func _handle_jump() -> void:
	if Input.is_action_just_pressed("Jump") and jumps_left > 0:
		velocity.y = jump_velocity
		jumps_left -= 1

# --- Momentum System ---
func _update_momentum(delta: float) -> void:
	var input_vector = Input.get_vector("Left", "Right", "Forward", "Back")
	if input_vector.length() == 0:
		_apply_friction(delta)
		return

	var input_dir = (head.transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()

	var applied_force = walk_force
	var base_speed = walk_base_speed
	if Input.is_action_pressed("Sprint"):
		applied_force = sprint_force
		base_speed = sprint_base_speed
	if is_sliding:
		applied_force *= slip_force_multiplier

	# Ensure minimum momentum
	if momentum.length() < base_speed:
		momentum = input_dir * base_speed

	var speed_ratio = clamp(momentum.length() / max_speed, 0, 1)
	var speed_factor = pow(1.0 - speed_ratio, 2)

	# Apply directional force
	var force = input_dir * applied_force * speed_factor
	momentum += force * delta

	# Steering
	var steer_strength = lerp(12.0, 3.0, speed_ratio)
	if is_sliding:
		steer_strength *= slip_steer_multiplier
	momentum = momentum.normalized().slerp(input_dir, steer_strength * delta) * momentum.length()

	# Reduce lateral drift
	var lateral = momentum - input_dir * momentum.dot(input_dir)
	var lateral_damp = lerp(10.0, 2.0, speed_ratio)
	momentum -= lateral * lateral_damp * delta

	# Snap low-speed direction
	if momentum.length() < walk_base_speed * 1.2:
		momentum = input_dir * momentum.length()

	# Opposite direction deceleration
	if momentum.dot(input_dir) < 0:
		momentum = momentum.move_toward(Vector3.ZERO, applied_force * delta)

	# Air control
	if not is_on_floor():
		momentum.x = lerp(momentum.x, momentum.x, air_control * delta)
		momentum.z = lerp(momentum.z, momentum.z, air_control * delta)


func _apply_friction(delta: float) -> void:
	var speed_ratio = clamp(momentum.length() / max_speed, 0, 1)
	var friction_strength = lerp(friction_low, friction_high, speed_ratio)
	if is_sliding:
		friction_strength *= slip_friction_multiplier
	momentum = momentum.move_toward(Vector3.ZERO, friction_strength * delta)

# --- Apply momentum to velocity ---
func _apply_velocity(delta) -> void:
	var final_velocity = momentum
	if is_dashing:
		final_velocity += dash_velocity

	if dash_velocity.length() > 0:
		dash_velocity *= dash_decay_multiplier * delta * 60
		if dash_velocity.length() < 0.01:
			dash_velocity = Vector3.ZERO

	velocity.x = final_velocity.x
	velocity.z = final_velocity.z
	$SpeedTest.text = "Speed: " + str(final_velocity.length())

func _handle_dash() -> void:
	if Input.is_action_just_pressed("Dashing") and not dash_cooldown_node.is_stopped():
		return

	if Input.is_action_just_pressed("Dashing") and dash_duration_node.is_stopped():
		# Determine dash direction
		var input_vector = Input.get_vector("Left", "Right", "Forward", "Back")
		var input_dir = (head.transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()

		if input_dir.length() == 0:
			dash_direction = momentum.normalized()
		else:
			dash_direction = input_dir

		if dash_direction.length() == 0:
			return

		# Activate dash
		is_dashing = true
		dash_velocity = dash_direction * dash_force
		dash_cooldown_node.start()
		dash_duration_node.start()



# --- Head Bob ---
func _update_headbob(delta: float) -> void:
	if Settings.head_bob_enabled:
		if !is_sliding:
			bob_timer += delta * momentum.length() * float(is_on_floor())
			camera.transform.origin = _headbob(bob_timer)

func _headbob(time: float) -> Vector3:
	return Vector3(cos(time * BOB_FREQ * 0.5), sin(time * BOB_FREQ), 0) * BOB_AMP

# --- Strafing ---
func _update_camera_tilt(delta: float) -> void:
	# Project momentum onto camera right direction
	var right_dir = head.transform.basis.x
	var lateral_speed = momentum.dot(right_dir)  # Positive = right, Negative = left

	# Target tilt based on lateral movement
	var target_tilt = clamp(-lateral_speed / max_speed * max_tilt_angle, -max_tilt_angle, max_tilt_angle)

	# Smoothly interpolate current tilt
	current_tilt = lerp(current_tilt, target_tilt, tilt_speed * delta)

	# Apply tilt around Z axis
	var rot = camera.rotation
	rot.z = deg_to_rad(current_tilt)
	camera.rotation = rot


# --- FOV ---
func _update_fov(delta: float) -> void:
	var target_fov = BASE_FOV + FOV_CHANGE * clamp(momentum.length(), 0.5, max_speed * 2)
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

func _on_dash_duration_timer_timeout() -> void:
	is_dashing = false
