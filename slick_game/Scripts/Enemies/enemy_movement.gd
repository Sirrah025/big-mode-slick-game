extends CharacterBody3D


@onready var nav_agent := $NavigationAgent3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_navigation_agent_3d_target_reached() -> void:
	pass # Replace with function body.


func _on_entity_died() -> void:
	pass # Replace with function body.
