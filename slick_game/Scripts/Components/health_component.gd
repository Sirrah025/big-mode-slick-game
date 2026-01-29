extends Node

@export var health := 100


func _on_damage(damage: int) -> void:
	health -= damage
