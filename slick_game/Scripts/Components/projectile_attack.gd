extends Node3D


@export var speed := 5.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var projectile = get_child(0)
	projectile.rotation.x = randf_range(-360.0, 360.0)
	projectile.rotation.y = randf_range(-360.0, 360.0)
	projectile.rotation.z = randf_range(-360.0, 360.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(speed * delta)
