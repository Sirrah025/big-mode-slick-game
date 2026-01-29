extends Node

@export var health := 100




func _on_hitbox_component_hit_box_hit(damage: int, speed_loss: float) -> void:
	health -= damage
