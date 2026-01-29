extends Node


func _on_entity_died() -> void:
	GlobalSignals.Player_Dies.emit()
