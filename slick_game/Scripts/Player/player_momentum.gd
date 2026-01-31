extends CharacterBody3D

# --- Movement Settings ---
@export var walk_base_speed: float = 5.0 
@export var sprint_base_speed: float = 9.0 
@export var walk_force: float = 2.5
@export var sprint_force: float = 8.0
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
@export var is_slipping: bool = false

# --- Crouching / Sliding ---
@export var slide_min_speed: float = 7.0

@export var crouch_walk_base_speed: float = 2.9
@export var crouch_walk_force: float = 0.2
@export var crouch_max_speed: float = 3.2
@export var slip_to_crouch_threshold: float = 5.0

@export var slide_decay_multiplier: float = 0.98
@export var sliding_speed_boost: float = 3.3
@export var can_slide_boost = true
@onready var slide_boost_cooldown_timer: Timer = $SlidingBoostCooldown

@export var stand_camera_y: float = 0.0
@export var crouch_camera_y: float = -0.5
@export var camera_height_lerp_speed: float = 8.0

@export var crouching_jump_boost = 1.8
@export var sliding_jump_boost = 1.3

@onready var head_clearance_ray: RayCast3D = $SpaceCheck

var is_sliding: bool = false
var is_crouching: bool = false
var was_on_floor: bool = false

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

var camera_base_y: float = 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/PlayerCamera

# --- Strafing ---
@export var max_tilt_angle: float = 8.0
@export var tilt_speed: float = 4.5
var current_tilt: float = 0.0 

# --- Head Bob ---
const BOB_FREQ: float = 1.6
const BOB_AMP: float = 0.09
var bob_timer: float = 0.0

# --- Hitboxes ---
@onready var normal_hitbox = $NormalHitBox
@onready var crouch_hitbox = $CrouchHitBox

# --- Runtime ---
var momentum: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	normal_hitbox.disabled = false
	crouch_hitbox.disabled = true
	can_slide_boost = true
	dash_duration_node.wait_time = dash_duration_time
	dash_cooldown_node.wait_time = dash_cooldown_time

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_slide_input()
	_handle_jump()
	_update_momentum(delta)
	_handle_dash()
	_apply_velocity(delta)
	_update_headbob(delta)
	_update_camera_tilt(delta)
	_update_camera_height(delta)
	_update_fov(delta)
	move_and_slide()

	_handle_landing()
	if is_crouching and can_stand() and !Input.is_action_pressed("Sliding"):
		_exit_crouch()

	if is_sliding and can_stand() and !Input.is_action_pressed("Sliding"):
		_exit_slide()
	was_on_floor = is_on_floor()

# --- Gravity ---
func _apply_gravity(delta: float) -> void:
	velocity.y = 0 if is_on_floor() else velocity.y - GRAVITY * delta

	# Reset jumps when on the floor
	if is_on_floor():
		jumps_left = max_jumps

# --- Sliding ---
func _handle_slide_input() -> void:
	if Input.is_action_just_pressed("Sliding") and is_on_floor():
		if momentum.length() >= slide_min_speed:
			_enter_slide()
		else:
			_enter_crouch()

	if Input.is_action_just_released("Sliding"):
		_exit_slide()
		_exit_crouch()

# --- Jump ---
func _handle_jump() -> void:
	if Input.is_action_just_pressed("Jump") and jumps_left > 0:
		# Prevent jumping if blocked above
		if is_crouching or is_sliding:
			if not can_stand():
				return

		var jump_boost = 1.0
		if is_crouching:
			jump_boost = crouching_jump_boost
		if is_sliding:
			jump_boost = sliding_jump_boost
		
		_exit_slide()
		_exit_crouch()
		
		velocity.y = jump_velocity * jump_boost
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

	if is_crouching:
		applied_force = crouch_walk_force
		base_speed = crouch_walk_base_speed
	elif Input.is_action_pressed("Sprint") and not is_sliding:
		applied_force = sprint_force
		base_speed = sprint_base_speed

	if is_slipping:
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
	if is_slipping:
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

	# Sliding momentum decay
	if is_sliding and !is_slipping:
		var slide_target_speed = crouch_max_speed

		# Only decay if above target speed
		if momentum.length() > slide_target_speed:
			# Scale decay based on current momentum (fast decay if slow, slow decay if fast)
			var slide_speed_ratio = clamp(momentum.length() / max_speed, 0, 1)
			var decay_strength = lerp(4.5, 1.5, slide_speed_ratio)  # tweak these for faster/slower decay
			# Apply delta-based decay
			momentum = momentum.move_toward(momentum.normalized() * slide_target_speed, decay_strength * delta)


	# Air control
	if not is_on_floor():
		momentum.x = lerp(momentum.x, momentum.x, air_control * delta)
		momentum.z = lerp(momentum.z, momentum.z, air_control * delta)

func _apply_friction(delta: float) -> void:
	var speed_ratio = clamp(momentum.length() / max_speed, 0, 1)
	var friction_strength = lerp(friction_low, friction_high, speed_ratio)

	if is_crouching:
		friction_strength *= 2.6
	
	if is_slipping:
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
	
	if final_velocity.length() < slip_to_crouch_threshold and is_sliding:
		_exit_slide()
		_enter_crouch()
	
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
	var bob_offset := Vector3.ZERO

	if Settings.head_bob_enabled and is_on_floor() and !is_slipping and !is_sliding:
		bob_timer += delta * momentum.length()
		bob_offset = _headbob(bob_timer)
	else:
		bob_timer = 0.0

	var pos := camera.transform.origin
	pos.y = camera_base_y + bob_offset.y 
	pos.x = 0
	pos.z = 0
	camera.transform.origin = pos

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

# --- Camera Height ---
func _update_camera_height(delta: float) -> void:
	var target_y := stand_camera_y

	if is_sliding or is_crouching:
		target_y = crouch_camera_y

	camera_base_y = lerp(camera_base_y, target_y, camera_height_lerp_speed * delta)

# --- FOV ---
func _update_fov(delta: float) -> void:
	var target_fov = BASE_FOV + FOV_CHANGE * clamp(momentum.length(), 0.5, max_speed * 2)
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

# --- Landing ---
func _handle_landing() -> void:
	# Just landed this frame
	if is_on_floor() and not was_on_floor:
		if Input.is_action_pressed("Sliding"):
			if momentum.length() >= slide_min_speed:
				_enter_slide()
			else:
				_enter_crouch()

# --- Handle Sliding States ---
func _enter_slide() -> void:
	if is_sliding:
		return
	is_sliding = true
	is_crouching = false

	normal_hitbox.disabled = true
	crouch_hitbox.disabled = false

	if momentum.length() < max_speed and can_slide_boost:
		momentum += (head.transform.basis.z * -1).normalized() * sliding_speed_boost
		can_slide_boost = false
		slide_boost_cooldown_timer.start()

func _exit_slide() -> void:
	if not is_sliding:
		return

	is_sliding = false

	if can_stand():
		is_crouching = false
		normal_hitbox.disabled = false
		crouch_hitbox.disabled = true
	else:
		is_crouching = true
		normal_hitbox.disabled = true
		crouch_hitbox.disabled = false


func _enter_crouch() -> void:
	if is_crouching:
		return

	is_crouching = true
	is_sliding = false

	# Enable crouch hitbox, disable normal
	normal_hitbox.disabled = true
	crouch_hitbox.disabled = false

	# Clamp momentum to crouch speed
	var speed = momentum.length()
	if speed > crouch_max_speed:
		momentum = momentum.normalized() * crouch_max_speed

func _exit_crouch() -> void:
	if not is_crouching:
		return

	if not can_stand():
		return

	is_crouching = false
	normal_hitbox.disabled = false
	crouch_hitbox.disabled = true

func can_stand() -> bool:
	# Returns true if nothing is blocking above the player
	return not head_clearance_ray.is_colliding()

func _on_dash_duration_timer_timeout() -> void:
	is_dashing = false

func _on_sliding_boost_cooldown_timeout() -> void:
	can_slide_boost = true
