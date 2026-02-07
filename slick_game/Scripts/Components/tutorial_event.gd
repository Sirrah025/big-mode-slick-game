extends Area3D

@onready var screen = $Control

func _on_body_entered(body: Node3D) -> void:
	screen.visible = true


func _on_body_exited(body: Node3D) -> void:
	#screen.visible = false
	queue_free()
