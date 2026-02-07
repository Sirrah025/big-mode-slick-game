extends Area3D

@export var gate : StaticBody3D
@export var open : bool

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: CharacterBody3D) -> void:
	if body.is_in_group("Player"):
		if open:
			gate.open()
		else:
			gate.close()
	
