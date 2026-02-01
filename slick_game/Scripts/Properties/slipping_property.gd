extends Area3D

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body: CharacterBody3D) -> void:
	if body.is_in_group("Player"):
		body.is_slipping = true
	
func _on_body_exited(body: CharacterBody3D) -> void:
	if body.is_in_group("Player"):
		body.is_slipping = false
