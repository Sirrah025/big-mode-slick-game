extends Area3D

@onready var screen = $Control

func _on_body_entered(body: Node3D) -> void:
	Control.visible = true


func _on_body_exited(body: Node3D) -> void:
	#Control.visible = false
	queue_free()
