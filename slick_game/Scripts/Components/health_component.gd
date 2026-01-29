extends Node

signal entity_died

@export var health := 100


func _on_damage(damage: int) -> void:
	health -= damage
	if health <= 0:
		entity_died.emit()
