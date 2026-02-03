extends Node3D

const PROJECTILE_SCENE = preload("res://Entities/Projectiles/ranged enemy projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_projectile(origin_path: NodePath):
	var origin = get_node(origin_path)
	var projectile = PROJECTILE_SCENE.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = origin.global_position
	projectile.global_rotation = get_parent().global_rotation
	
