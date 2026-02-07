extends CharacterBody3D

@export var speed = 5.0
var player_target: CharacterBody3D

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


func _movement() -> void:
	if flying:
		if !target_pos:
			target_pos = _grab_player_pos()
