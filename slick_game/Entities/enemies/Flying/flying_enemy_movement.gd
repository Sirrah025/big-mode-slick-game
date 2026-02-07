extends CharacterBody3D

@export var speed = 5.0
@export var turn_speed = 4.0
var player_target: CharacterBody3D

@onready var Forward_Direction = $ForwardDirection
@onready var death_sound = %"Enemy Death"

var flying = false
var target_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_target = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_movement()

func _grab_player_pos() -> Vector3:
	return player_target.global_position

func _calculate_target_vector() -> Vector3:
	var base = _grab_player_pos()
	var direction = global_position.direction_to(base)
	direction = Vector3(randf_range(-0.7, 0.7) + direction.x, 0, randf_range(-0.7, 0.7) + direction.z)
	return direction.normalized()

func _movement() -> void:
	if flying:
		if !target_pos:
			target_pos = _calculate_target_vector()
		velocity = target_pos * speed
		if not player_target.is_equal_approx(global_position):
			look_at(Vector3(player_target.x, player_target.y, player_target.z), Vector3.UP)
			rotate_y(deg_to_rad(Forward_Direction.rotation.y * turn_speed)) 
	move_and_slide()


func _on_health_component_entity_died() -> void:
	death_sound.play_random_audio()
	queue_free()
