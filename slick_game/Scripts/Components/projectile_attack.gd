extends Node3D


@export var speed := 5.0

var forward_direction: Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var projectile = get_child(0)
	forward_direction = Vector3.FORWARD
	projectile.rotation.x = randf_range(-360.0, 360.0)
	projectile.rotation.y = randf_range(-360.0, 360.0)
	projectile.rotation.z = randf_range(-360.0, 360.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(speed * delta)
	global_position += forward_direction * speed * delta
