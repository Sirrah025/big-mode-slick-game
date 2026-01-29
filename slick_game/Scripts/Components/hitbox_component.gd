extends Area3D

signal hit_box_hit(damage: int, speed_loss: float)


func _emit_hit_box_signal() -> void:
	hit_box_hit.emit(5, 2.0)


func _on_body_entered(body: Node3D) -> void:
	_emit_hit_box_signal()


func _on_area_entered(area: Area3D) -> void:
	_emit_hit_box_signal()
